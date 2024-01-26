//
//  Tabs.swift
//  tbb
//
//  Created by Mary Etefia on 8/6/23.
//  Copyright © 2023 Study Aloud. All rights reserved.
//

import FirebaseFirestore
import SwiftUI

struct VerseReference {
    var book: String
    var chapter: Int
    var verse: Int
    var translation: String

    var description: String {
        "\(book) \(chapter): \(verse)"
    }
}

struct Tabs: View {
    @StateObject private var userManager = UserManager.shared
    @EnvironmentObject private var appRootManager: AppRootManager

    @State private var selection = 0
    @State private var tabBarHeight = 0.0
    
    @State private var verseReference: VerseReference = VerseReference(book: "Genesis", chapter: 1, verse: 1, translation: "KJV")

    var body: some View {
        // Using NavigationStack instead makes all toolbars disappear
        NavigationView {
            ZStack {
                VStack(alignment: .leading) {
                    TabView(selection: $selection) {
                        Home()
                            .tabItem {
                                Label("Home", image: "home-fill")
                            }
                            .tag(0)
                        Read(verseReference: $verseReference)
                            .tabItem {
                                Label("Read", image: "read")
                            }
                            .tag(1)
                        // TODO: Replace the folowing line with Buddie() chat bot
                        Text("Buddie")
                            .tag(2)
                        Journal()
                            .tabItem {
                                Label("Journal", image: "journal-tab")
                            }
                            .tag(3)
                        Profile()
                            .tabItem {
                                Label("Profile", image: "profile2")
                            }
                            .tag(4)
                    }
                    .accentColor(Color(.appOrange))
                }
                .background(.white)
                .ignoresSafeArea()
                
                Image("chat-unread-button")
                    .onTapGesture {
                        selection = 2
                    }
                    .background(Circle().stroke(Color(.appGray), lineWidth: 2.0).background(.white).frame(width: 80.0, height: 80.0).clipShape(Circle()))
                    .position(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.maxY - tabBarHeight)
            }
            // Necessary to get correct position buddie button
            .ignoresSafeArea()
        }
        .navigationBarBackButtonHidden(true)
        .onReceive(notificationCenter.publisher(for: .tabBarHeight), perform: { height in
            if let height = height.object as? Double {
                self.tabBarHeight = height
            }
        })
        .onAppear() {
            appRootManager.currentRoot = .tabs
            
            // Update streak if needed
            let firestore = Firestore.firestore()
            Task {
                do {
                    let userDocument = try await firestore.collection("users").document(userManager.email).getDocument()
                    if let lastVisit = userDocument.get("lastVisit") as? Timestamp, let streak = userDocument.get("streak") as? Int {
                        let calendar = Calendar.current
                        let lastVisitDate = lastVisit.dateValue()
                        
                        if let followingVisit = calendar.date(byAdding: .day, value: 1, to: lastVisitDate) {
                            let todayComps = Calendar.current.dateComponents([.month, .day, .year], from: .now)
                            let followingVisitComps = calendar.dateComponents([.month, .day, .year], from: followingVisit)
                            if todayComps.month == followingVisitComps.month && todayComps.day == followingVisitComps.day && todayComps.year == followingVisitComps.year {
                                try await firestore.collection("users").document(userManager.email).setData(["streak": streak + 1], merge: true)
                            } else {
                                try await firestore.collection("users").document(userManager.email).setData(["streak": 0], merge: true)
                            }
                        }
                    }
                } catch(let error) {
                    print(error)
                }
            }
        }
    }
}

extension UITabBarController {
    override open func viewDidLayoutSubviews() {
        self.tabBar.backgroundColor = UIColor(resource: .appEggWhite)
        
        notificationCenter.post(name: .tabBarHeight, object: self.tabBar.frame.size.height)
        
        if let items = self.tabBar.items {
            for itemTag in 0...(items.count - 1) {
                items[itemTag].titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 15.0)
                items[itemTag].imageInsets = UIEdgeInsets(top: 10, left: 0, bottom: -10, right: 0)
            }
        }
    }
}

#Preview {
    Tabs()
}
