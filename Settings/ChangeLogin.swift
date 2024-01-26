//
//  ChangeLogin.swift
//  tbb
//
//  Created by Mary Etefia on 10/15/23.
//  Copyright © 2023 Study Aloud. All rights reserved.
//

import SwiftUI

struct ChangeLogin: View {
    @Environment(\.dismiss) private var dismiss
    @State var email = ""
    @State var sentPasswordChangeRequest = false
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20.0) {
                Text("Email")
                    .fontWeight(.semibold)
                ResponseField(hint: "Email", response: $email)
                Button("Submit Request") {
                    sentPasswordChangeRequest = true
                }
                .foregroundStyle(Color(.appDarkBlue))
                .alert(isPresented: $sentPasswordChangeRequest) {
                    if email.isEmpty {
                        Alert(
                            title: Text("Please enter your email address."),
                            dismissButton: .destructive(Text("Okay"))
                        )
                    } else {
                        Alert(
                            title: Text("Password Change Request"),
                            message: Text("Please check your email to proceed with your password change request."),
                            dismissButton: .destructive(Text("Okay"))
                        )
                    }
                }
                
                Spacer()
            }
            .padding()
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color(.appEggWhite), for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    BackButton(title: "Login Credentials", dismissAction: dismiss)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    ChangeLogin()
}
