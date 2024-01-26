//
//  AppRootManager.swift
//  tbb
//
//  Created by Mary Etefia on 11/22/23.
//  Copyright © 2023 Study Aloud. All rights reserved.
//

import FirebaseAuth
import Foundation

final class AppRootManager: ObservableObject {
    @Published var currentRoot: Roots = .onboarding
    
    init() {
        if let user = Auth.auth().currentUser, let preferredName = user.displayName, let email = user.email {
            UserManager.shared.preferredName = preferredName
            UserManager.shared.email = email
            currentRoot = .tabs
        }
    }
    
    enum Roots {
        case onboarding
        case authentication
        case tabs
    }
}
