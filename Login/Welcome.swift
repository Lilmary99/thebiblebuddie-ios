//
//  Welcome.swift
//  tbb
//
//  Created by Mary Etefia on 8/6/23.
//  Copyright © 2023 Study Aloud. All rights reserved.
//

import Foundation
import SwiftUI

struct Welcome: View {
    @EnvironmentObject private var appRootManager: AppRootManager

    var body: some View {
        NavigationStack {
            VStack(alignment: .center, spacing: 20.0) {
                Image(.logo)
                    .resizable()
                    .frame(width: 301, height: 281)
                Text("Welcome to")
                    .font(.custom("Roboto", size: 20.0))
                Text("Bible Buddie")
                    .font(.custom("Roboto", size: 30.0))
                    .fontWeight(.bold)
                    .padding(.bottom, 50)
                
                NavigationLink(destination: SignUp()) {
                    Text("Let's Begin")
                        .frame(maxWidth: 263)
                }
                .tbbCapsuleStyle()
                
                NavigationLink(destination: SignIn()) {
                    Text("I already have an account")
                        .foregroundColor(Color(.appDarkBlue))
                }
                .font(.body)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear() {
            appRootManager.currentRoot = .authentication
        }
    }
}

#Preview {
    Welcome()
}
