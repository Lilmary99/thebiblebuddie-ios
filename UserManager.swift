//
//  UserManager.swift
//  tbb
//
//  Created by Mary Etefia on 11/24/23.
//  Copyright © 2023 Study Aloud. All rights reserved.
//

import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import Foundation
import GoogleSignIn
import os

class UserManager: ObservableObject {
    static let shared = UserManager()
    let firestore = Firestore.firestore()

    public var preferredName = ""
    public var email = "" {
        didSet { email = email.lowercased() }
    }
    
    // TODO: Convert the following two funcs into one getProfileQuery func?
    @Published public var streak: Int = 0
    @MainActor public func getStreak() async {
        do {
            let userDocument = try await firestore.collection("users").document(email).getDocument()
            if let streak = userDocument.get("streak") as? Int {
                self.streak = streak
            }
        } catch(let error) {
            // TODO: Log the error
            print(error)
        }
    }
    
    @Published public var joinDate: String = ""
    @MainActor public func getJoinDate() async {
        do {
            let userDocument = try await firestore.collection("users").document(email).getDocument()
            if let date = userDocument.get("join-date") as? Timestamp {
                let joinDate = date.dateValue()
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                self.joinDate = dateFormatter.string(from: joinDate)
            }
        } catch(let error) {
            // TODO: Log the error
            print(error)
        }
    }
    
    public func subscribeToReminders() async {
        do {
            let querySnapshot = try await firestore.collection("users/\(email)/reminders").getDocuments()
            for reminder in querySnapshot.documents {
                if let date = reminder.get("date") as? Timestamp,
                   let label = reminder.get("label") as? String,
                   let isEnabled = reminder.get("isEnabled") as? Bool,
                   let selectedDays = reminder.get("selectedDays") as? [String] {
                    if isEnabled {
                        subscribeToReminder(reminderID: reminder.documentID, date: date.dateValue(), label: label, selectedDays: selectedDays)
                    }
                }
            }
        } catch(let error) {
            // TODO: Log the error
            print(error)
        }
    }
    
    public func unsubscribeFromNotifications() {
        // Unsubscribe from local
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // Unsubscribe from remote
        UIApplication.shared.unregisterForRemoteNotifications()
    }
    
    func addUserToDatabase() {
        // Add fields
        Firestore.firestore().collection("users").document(email)
            .setData(["language": Locale.current.language.languageCode?.identifier ?? "en",
                      "join-date": FieldValue.serverTimestamp(),
                      "last-visit": FieldValue.serverTimestamp(),
                      "streak": 0,
                      "preferred-name": preferredName,
                      "current-translation": "kjv",
                      "current-verse": "Genesis-1-1",
                      "goals": [],
                      "completed-goals": [],
                      "fruits": [],
                      "interests": [],
                     ])
        
        // Collections get added once you write to them, accessing them without a documents will safely return nil
    }
    
    /* Returns string representation of alert message code, if one is present */
    public func registerUser(named preferredName: String, using email: String, password: String) async -> String? {
        do {
            // create user
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.email = email
            self.preferredName = preferredName
            addUserToDatabase()
            
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    // TODO: Error handle
                if success {
                    Task {
                        await self.subscribeToReminders()
                    }
                }
            }
            
            // set display name in database
            let profileRequest = result.user.createProfileChangeRequest()
            profileRequest.displayName = preferredName
            try await profileRequest.commitChanges()
        } catch(let error) {
            if let authError = error as? AuthErrorCode {
                logger.error("Could not create user: \(authError.localizedDescription)")

                switch authError.code {
                case .emailAlreadyInUse:
                    return "This email address is already registered."
                case .invalidEmail:
                    return "Could not validate email address. Please try again."
                case .missingEmail:
                    return "Please enter an email address."
                case .networkError:
                    return "Please connect to the internet and try again."
                case .weakPassword:
                    return "Password cannot be less than 6 characters"
                default:
                    return "Could not create user. Please verify all fields are correct and try again."
                }
            }

            logger.error("Could not set user display name, \(preferredName): \(error.localizedDescription)")
            return "Could not create user. Please verify all fields are correct and try again."
        }
        return nil
    }
    
    /* Returns string representation of alert message code, if one is present */
    public func authorizeUser(using email: String, password: String) async -> String? {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            if let preferredName = result.user.displayName {
                self.preferredName = preferredName
            }
            self.email = email
            
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    // TODO: Error handle
                if success {
                    Task {
                        await self.subscribeToReminders()
                    }
                }
            }
        } catch(let error) {
            if let authError = error as? AuthErrorCode {
                logger.error("Could not sign user in: \(authError.localizedDescription)")

                switch authError.code {
                case .invalidEmail:
                    return "Could not validate email address. Please try again."
                case .missingEmail:
                    return "Please enter an email address."
                case .networkError:
                    return "Please connect to the internet and try again."
                default:
                    return "Could not create user. Please verify all fields are correct and try again."
                }
            }
        }
        return nil
    }
    
    /* Returns string representation of alert message code, if one is present */
    public func passwordReset(for userEmail: String) async -> String? {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: userEmail)
        } catch(let error) {
            if let authError = error as? AuthErrorCode {
                logger.error("Could not send passowrd reset email: \(authError.localizedDescription)")
            }
            return "Failure trying to reset passowrd. Please verify your email is registered with us and try again."
        }
        return nil
    }
    
    /* Returns string representation of alert message code, if one is present */
    @MainActor
    public func authorizeGoogleUser(forSignUp: Bool) async -> String? {
        if let clientId = FirebaseApp.app()?.options.clientID {
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientId)
            
            // begin user registration with app
            // TODO: Ensure the following constant declartions do not need an `await` keyword
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first,
                  let rootViewController = window.rootViewController else {
                logger.error("There is no root view controller!")
                return "Error. Please try again later."
            }
            
            do {
                let userResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
                
                if let idToken = userResult.user.idToken?.tokenString {
                    let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: userResult.user.accessToken.tokenString)
                    
                    // sign in
                    try await Auth.auth().signIn(with: credential)
                    
                    if let profile = userResult.user.profile, let preferredName = profile.givenName {
                        self.email = profile.email
                        self.preferredName = preferredName
                    }
                    
                    if forSignUp {
                        addUserToDatabase()
                    }
                    
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                            // TODO: Error handle
                        if success {
                            Task {
                                await self.subscribeToReminders()
                            }
                        }
                    }
                }
            } catch(let error) {
                if let gidError = error as? GIDSignInError {
                    logger.error("Could not sign in google user using `GIDSignIn.sharedInstance.signIn(withPresenting:)`: \(gidError.localizedDescription)")
                    return "Sign in with Google failed. Please try again."
                }
                
                if let authError = error as? AuthErrorCode {
                    logger.error("Could not sign in Google user using `Auth.auth(app:)`: \(authError.localizedDescription)")
                    switch authError.code {
                    case .emailAlreadyInUse:
                        return "This email address is already registered."
                    case .networkError:
                        return "Please connect to the internet and try again."
                    default:
                        return "Sign in with Google failed. Please try again."
                    }
                }
            }
        }
        return nil
    }
    
    public func logout() throws {
        try Auth.auth().signOut()
        unsubscribeFromNotifications()
    }
}
