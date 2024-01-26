//
//  Fruits.swift
//  tbb
//
//  Created by Mary Etefia on 10/15/23.
//  Copyright © 2023 Study Aloud. All rights reserved.
//

import SwiftUI

// TODO: Complete onTapGesture logic once you incorporate Firebase support (dont send distributed notifications?, just update database and have state vars respond to updates)
// TODO: Then call onReceive of database updates
struct Fruits: View {
    @Environment(\.dismiss) private var dismiss
    @State var response: String = ""
    
    // TODO: Firebase support
    @State var fruits: [String] = ["Compassion", "Love", "Patience"]
    @State var selectedFruits: [String] = ["Kindness", "Faith", "Forgiveness"]
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 10.0) {
                Text("Select 3 Fruits that you would like to build upon this season. \n\nThe Fruits are Christian qualities that you would hope to embody or improve. Update these fruit during different seasons in your life.")
                ResponseField(hint: "Type to pick suggested fruit", response: $response)
                
                Text("Suggested Fruits")
                    .fontWeight(.bold)
                //                        .onTapGesture {
                //                            // Move topic to next section
                //                            selectedFruits.append(fruit)
                //                        }
                WrappedList(isSuggestion: true, activities: fruits)
                
                Divider()
                
                Label("Your Fruits", image: "fruit")
                    .fontWeight(.bold)
                //                        .onTapGesture {
                //                            // TODO: Remove topic from Firebase as well
                //                            selectedFruits.remove(at: index)
                //                        }
                
                WrappedList(activities: selectedFruits)
            }
            .padding()
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color(.appEggWhite), for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    BackButton(title: "Fruits of the Season", dismissAction: dismiss)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    Fruits()
}
