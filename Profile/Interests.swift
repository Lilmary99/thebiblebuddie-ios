//
//  Interests.swift
//  tbb
//
//  Created by Mary Etefia on 9/10/23.
//  Copyright © 2023 Study Aloud. All rights reserved.
//

import SwiftUI

// TODO: Complete onTapGesture logic once you incorporate Firebase support (dont send distributed notifications?, just update database and have state vars respond to updates)
// TODO: Then call onReceive of database updates
struct Interests: View {
    @Environment(\.dismiss) private var dismiss
    @State var response: String = ""
    
    // TODO: Firebase support
    @State var topics: [String] = ["Jews", "Sin", "Jesus"]
    @State var selectedTopics: [String] = ["New Testament", "Heaven", "Prayer", "Sin", "Hell", "Prophecy", "Traditions"]
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 10.0) {
                Text("Select 7 topics that you are interested in learning more about.")
                ResponseField(hint: "Type to pick suggested topics", response: $response)
                
                Text("Suggested Topics")
                    .fontWeight(.bold)
                //                        .onTapGesture {
                //                            // Move topic to next section
                //                            selectedTopics.append(topic)
                //                        }
                WrappedList(isSuggestion: true, activities: topics)
                
                Divider()
                
                Label("Your Interests", image: "flag")
                    .fontWeight(.bold)
                //                        .onTapGesture {
                //                            // TODO: Remove topic from Firebase as well
                //                            selectedTopics.remove(at: index)
                //                        }
                WrappedList(activities: selectedTopics)
            }
            .padding()
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color(.appEggWhite), for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    BackButton(title: "Interests", dismissAction: dismiss)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    Interests()
}
