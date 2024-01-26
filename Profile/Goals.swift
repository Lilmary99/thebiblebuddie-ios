//
//  Goals.swift
//  tbb
//
//  Created by Mary Etefia on 10/15/23.
//  Copyright © 2023 Study Aloud. All rights reserved.
//

import SwiftUI

// TODO: Complete onTapGesture logic once you incorporate Firebase support (dont send distributed notifications?, just update database and have state vars respond to updates)
// TODO: Then call onReceive of database updates
// TODO: Implement "Drag to Complete" after Firebase is hooked up
// TODO: Implement alert for tapping on completed goal
// TODO: Use dropdown instead for suggestions
struct Goals: View {
    @Environment(\.dismiss) private var dismiss
    @State var response: String = ""
    
    // TODO: Firebase support
    @State var goals: [String] = ["Read New Testament", "Practice", "Pray everyday this week", "Worship"]
    @State var selectedGoals: [String] = ["Journal for 14 days", "Pray for 30 days", "Learn about love"]
    @State var completedGoals: [String] = []
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 10.0) {
                Text("Choose 3 goals. You can always update later.")
                ResponseField(hint: "Type to pick suggested goals", response: $response)
                
                Text("Suggested Goals")
                    .fontWeight(.bold)
                //                        .onTapGesture {
                //                            // Move topic to next section
                //                            selectedGoals.append(topic)
                //                        }
                WrappedList(isSuggestion: true, activities: goals)
                
                Divider()
                
                Label("Goals in Progress", image: "flag")
                    .fontWeight(.bold)
                //                        .onTapGesture {
                //                            // TODO: *Move topic in Firebase as well
                //                            completedGoals.append(selectedGoal)
                //                        }
                WrappedList(activities: selectedGoals)
                
                Divider()
                
                TBBLabel(label: "Completed Goals", icon: "trophy")
                    .fontWeight(.bold)
                // TODO: Replace "plus" with "minus" and:
                //                        .onTapGesture {
                //                            // TODO: Remove topic from Firebase as well
                //                            completedGoals.remove(at: index)
                //                        }
                WrappedList(activities: completedGoals)
            }
            .padding()
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color(.appEggWhite), for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    BackButton(title: "Goals", dismissAction: dismiss)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    Goals()
}
