//
//  TheBibleBuddie.swift
//  tbb
//
//  Created by Mary Etefia on 8/5/23.
//  Copyright © 2023 Study Aloud. All rights reserved.
//

import FirebaseCore
import GoogleSignIn
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
      FirebaseApp.configure()
      return true
  }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
      return GIDSignIn.sharedInstance.handle(url)
    }
}

@main
struct TheBibleBuddie: App {
    @StateObject private var appRootManager = AppRootManager()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    init() {
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                switch appRootManager.currentRoot {
                case .onboarding:
                    Onboarding()
                case .authentication:
                    Welcome()
                case .tabs:
                    Tabs()
                }
            }
            .environmentObject(appRootManager)
        }
    }
}
