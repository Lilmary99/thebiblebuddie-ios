//
//  Onboarding.swift
//  tbb
//
//  Created by Mary Etefia on 8/5/23.
//  Copyright © 2023 Study Aloud. All rights reserved.
//

import SwiftUI
import UIKit

struct Onboarding: View {
    @State private var selection = 0
    
    init() {
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(Color(.appDarkBlue))
        UIPageControl.appearance().pageIndicatorTintColor = UIColor(Color(.appBlue))
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                HStack {
                    Spacer()
                    NavigationLink(destination: Welcome()) {
                        Text("Skip")
                    }
                    .font(.body)
                    .foregroundStyle(Color(.appDarkGray))
                }
                
                TabView(selection: $selection) {
                    HeadingAndSummary(heading: "Personalize Your Experience",
                                      summary: "Your guide Buddie will navigate you through an experience customized just for you through daily recommended readings, personalized reminders, suggested goals to improve biblical literacy.")
                    .tag(0)
                    
                    HeadingAndSummary(heading: "Stay on Track",
                                      summary: "Buddie will encourage you to stay on track through daily interactions, reminders that fit in your schedule, and writing prompts that will spark consistency for the long run. ")
                    .tag(1)
                    
                    HeadingAndSummary(heading: "Read Interactively",
                                      summary: "Have a conversation with Buddie on biblical topics and interests to learn more.")
                    .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                
                if selection == 2 {
                    HStack {
                        Spacer()
                        NavigationLink(destination: Welcome()) {
                            Text("Begin")
                        }
                        .tbbCapsuleStyle()
                    }
                    .padding(.top, -50)
                }
            }
            .padding()
        }
        .disabled(false)
    }
}

struct HeadingAndSummary: View {
    let heading: String
    let summary: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20.0) {
            Text(heading)
                .font(.custom("Roboto", size: 30.0))
                .fontWeight(.bold)
            Text(summary)
                .font(.body)
        }
    }
}

#Preview {
    Onboarding()
}
