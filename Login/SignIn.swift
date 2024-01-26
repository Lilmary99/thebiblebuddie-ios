//
//  SignIn.swift
//  tbb
//
//  Created by Mary Etefia on 8/6/23.
//  Copyright © 2023 Study Aloud. All rights reserved.
//

import SwiftUI

struct SignIn: View {
    @State private var email = ""
    @State private var password = ""
    @State private var authSuccess = false
    
    let userManager = UserManager.shared
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center, spacing: 20.0) {
                Image(.logo)
                    .resizable()
                    .frame(width: 128, height: 120)
                // TODO: Replace "Matt" with database name
                Text("Welcome!")
                    .fontWeight(.bold)
                    .font(.custom("Roboto", size: 20.0))
                Text("Sign in to continue your journey.")
                    .font(.body)
                    .foregroundColor(Color(.appDarkGray))
                
                ResponseField(hint: "Email", response: $email)
                ResponseField(hint: "Password", isPassword: true, response: $password)
                
                HStack {
                    Spacer()
                    Button(action: {
                        // TODO: this should be its own dialog box
                        Task {
                            if let error = await userManager.passwordReset(for: email) {
                                // TODO: Show alert message using `result` string
                                print(error)
                            } else {
                                // TODO: Convert this print statement to alert message
                                print("Please check your email for a password reset link.")
                            }
                        }
                    }, label: {
                        Text("Forgot Password?")
                            .foregroundColor(Color(.appDarkBlue))
                    })
                }
                .padding(.bottom, 30.0)
                
                Button(action: {
                    Task {
                        if let result = await userManager.authorizeUser(using: email, password: password) {
                            // TODO: Show alert message using `result` string
                            print(result)
                        } else {
                            authSuccess = true
                        }
                    }
                }, label: {
                    Text("Login")
                        .frame(maxWidth: 263)
                })
                .tbbCapsuleStyle()
                
                Text("or continue with")
                HStack {
                    Button(action: {
                        Task {
                            if let result = await userManager.authorizeGoogleUser(forSignUp: false) {
                                // TODO: Show alert message using `result` string
                                print(result)
                            } else {
                                authSuccess = true
                            }
                        }
                    }, label: {
                        Image("google")
                    })
                    
                    Divider()
                        .frame(height: 62.0)

                    Button(action: {
                        // TODO: Implement facebook and apple sign in
                    }, label: {
                        Image(.facebook)
                    })
                }
//                .frame(height: 75)
            }
            .padding()
            .navigationDestination(isPresented: $authSuccess) {
                Tabs()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    SignIn()
}
