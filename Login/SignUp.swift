//
//  SignUp.swift
//  tbb
//
//  Created by Mary Etefia on 8/6/23.
//  Copyright © 2023 Study Aloud. All rights reserved.
//

import SwiftUI

struct SignUp: View {
    @State private var preferredName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var authSuccess = false
    
    let termsURL = ""
    let privacyPolicyURL = ""
    let userManager = UserManager.shared
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center, spacing: 20.0) {
                Image("logo")
                    .resizable()
                    .frame(width: 128, height: 120)
                Text("Sign up to start your journey.")
                    .font(.body)
                    .foregroundColor(Color(.appDarkGray))
                    .padding(.bottom, 20)
                
                ResponseField(hint: "Preferred Name", response: $preferredName)
                ResponseField(hint: "Email", response: $email)
                ResponseField(hint: "Password", isPassword: true, response: $password)
                
                Text("By signing up you agree to Bible Buddy's \n[Terms and Conditions](termsURL) and [Privacy Policy](privacyPolicyURL).")
                    .padding(.bottom, 30)

                Button(action: {
                    Task {
                        if let result = await userManager.registerUser(named: preferredName, using: email, password: password) {
                            // TODO: Show alert message using `result` string
                            print(result)
                        } else {
                            authSuccess = true
                        }
                    }
                }) {
                    Text("Sign Up")
                        .frame(maxWidth: 263)
                }
                .tbbCapsuleStyle()
                
                Text("or continue with")
                HStack {
                    Button(action: {
                        Task {
                            if let result = await userManager.authorizeGoogleUser(forSignUp: true) {
                                // TODO: Show alert message using `result` string
                                print(result)
                            } else {
                                authSuccess = true
                            }
                        }
                    }, label: {
                        Image(.google)
                    })
                    
                    Divider()
                        .frame(height: 62.0)
                    
                    Button(action: {
                        // TODO: Implement facebook and apple sign in
                    }, label: {
                        Image(.facebook)
                    })
                }
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
    SignUp()
}
