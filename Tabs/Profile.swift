//
//  Profile.swift
//  tbb
//
//  Created by Mary Etefia on 9/10/23.
//  Copyright © 2023 Study Aloud. All rights reserved.
//

import SwiftUI

// TODO: Replace all hardcoded user info with database info
struct Profile: View {
    @StateObject private var userManager = UserManager.shared

    @State private var showSettings = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20.0) {
                    // Streak
                    TBBLabel(label: "\(userManager.streak) Day Streak", icon: "streak")
                        .task {
                            await userManager.getStreak()
                        }
                    
                    // TODO: The following 3 texts should be replaced if DB says activity exists
                    HStack {
                        TBBLabel(label: "Goals", icon: "trophy")
                        Spacer()
                        NavigationLink(destination: Goals()) {
                            Image(.chevron)
                        }
                    }
                    Text("Choose 3 goals. You can always update later.")
                    
                    HStack {
                        TBBLabel(label:"Fruit of the Season", icon: "fruit")
                        Spacer()
                        NavigationLink(destination: Fruits()) {
                            Image(.chevron)
                        }
                    }
                    Text("Select 3 Spiritual Fruits that you would like to build upon this season. You can always update later.")
                    
                    HStack {
                        TBBLabel(label: "Interests", icon: "lightbulb")
                        Spacer()
                        NavigationLink(destination: Interests()) {
                            Image(.chevron)
                        }
                    }
                    Text("Select 7 topics that you are interested in learning more about. You can always update later.")
                }
                .padding()
            }
            .navigationDestination(isPresented: $showSettings, destination: {
                Settings()
            })
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color(.appEggWhite), for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Image(.profile)
                        .resizable()
                        .frame(width: 50, height: 50)
                }
                ToolbarItem(placement: .topBarLeading) {
                    VStack(alignment: .leading) {
                        Text(userManager.preferredName)
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Joined \(userManager.joinDate)")
                            .font(.body)
                            .task {
                                await userManager.getJoinDate()
                            }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showSettings.toggle() }, label: {
                        Image(.gear)
                    })
                }
            }
        }
    }
}

#Preview {
    Profile()
}
