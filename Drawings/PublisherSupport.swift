//
//  PublisherSupport.swift
//  tbb
//
//  Created by Mary Etefia on 11/21/23.
//  Copyright © 2023 Study Aloud. All rights reserved.
//

import Foundation

let notificationCenter = NotificationCenter.default

extension Notification.Name {
    // Tabs
    static let tabBarHeight = NSNotification.Name(rawValue: "tabBarHeight")
    static let profileActivityType = NSNotification.Name(rawValue: "profileActivityType")
    
    // Journal
    static let editingComplete = NSNotification.Name(rawValue: "editingComplete")
}
