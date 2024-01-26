//
//  Home.swift
//  tbb
//
//  Created by Mary Etefia on 8/6/23.
//  Copyright © 2023 Study Aloud. All rights reserved.
//

import SwiftUI

struct Home: View {
    @StateObject private var userManager = UserManager.shared
    @State private var didYouKnow = "The people of Egypt were...Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean aliquet Lorem ipsum"
    @State private var letsChat = "Last time you were here you were reading Revelations. Pretty intense! I’d love to talk to you about what you read."
    @State private var openMetrics = false
    
    var greeting: String {
        let now = Date.now
        let calendar = Calendar(identifier: .gregorian)
        let timeOfDay = calendar.component(.hour, from: now)
        if (timeOfDay < 12) {
            return "Good Morning"
        }
        else if (timeOfDay > 12 && timeOfDay <= 16) {
            return "Good Afternoon"
        }
        return "Good Evening"
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20.0) {
                    Text("\(greeting), \(userManager.preferredName)")
                        .fontWeight(.bold)
                        .font(.custom("Roboto", size: 20.0))
                    
                    HStack(spacing: 10.0) {
                        TBBLabel(label: "0% Read", icon: "book")
                        TBBLabel(label: "\(UserManager.shared.streak) Day Streak", icon: "streak")
                    }
                    .task { await userManager.getStreak() }

                    // TODO: Replace Goals()
                    Button(action: { openMetrics = true }, label: {
                        HStack {
                            Text("More Metrics")
                                .foregroundStyle(Color(.appBlack))
                            Spacer()
                            Image(.chevron)
                        }
                    })
                    .fontWeight(.semibold)
                    
                    Card(label: "Did You Know?", icon: "lightbulb", detail: didYouKnow)
                    Card(label: "Let's Chat!", icon: "chat-unread", detail: letsChat)
                    
                    ScriptureCard(label: "Recommended Readings", titleByVerseID: ["Title":"verseID", "Title2":"verseID"])
                    ScriptureCard(label: "Trending Readings", titleByVerseID: ["Title":"verseID"])
                }
                .padding()
                .navigationDestination(isPresented: $openMetrics) { Goals() }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color(.appEggWhite), for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Image(.banner)
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Image(.bannerText)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct Card: View {
    let label: String
    let icon: String
    let detail: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 10.0) {
                TBBLabel(label: label, icon: icon)
                Text(detail)
                    .font(.body)
                Spacer()
            }
            Spacer()
        }
        .padding()
        .homescreenClipStyle()
    }
}

struct MiniCard: View {
    let scripture: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(scripture)
                    .padding()
                    .foregroundStyle(Color(.appBlack))
                Spacer()
            }
            Spacer()
        }
        .frame(width: 110, height: 121)
        .background(
            RoundedRectangle(cornerRadius: 16.0)
                .shadow(radius: 2)
                .foregroundStyle(Color(.appBlue))
        )
    }
}

struct ScriptureCard: View {
    let label: String
    let titleByVerseID: [String: String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10.0) {
            Text(label)
                .fontWeight(.semibold)
            
            ScrollView(.horizontal) {
                HStack(spacing: 20) {
                    ForEach(Array(titleByVerseID.keys), id: \.self) { scripture in
                        // TODO: Replace Text(scripture) with a NavigationLink that opens a view initialized with titleByVerseID[scripture]
                        MiniCard(scripture: scripture)
                    }
                }
            }
        }
        .padding()
        .homescreenClipStyle()
    }
}

#Preview {
    Home()
}
