//
//  SwiftUIView.swift
//  tbb
//
//  Created by Mary Etefia on 11/14/23.
//  Copyright © 2023 Study Aloud. All rights reserved.
//

import SwiftUI

struct WrappedList: View {
    let isSuggestion: Bool
    let activities: [String]
    
    init(isSuggestion: Bool = false, activities: [String]) {
        self.isSuggestion = isSuggestion
        self.activities = activities
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            GeometryReader { geometry in
                self.generateContent(in: geometry)
            }
        }
        .frame(height: 150.0)
    }

    private func generateContent(in g: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(self.activities, id: \.self) { activity in
                self.item(for: activity)
                    .padding([.horizontal, .vertical], 4)
                    .alignmentGuide(.leading, computeValue: { d in
                        if (abs(width - d.width) > g.size.width) {
                            width = 0
                            height -= d.height
                        }
                        let result = width
                        if activity == self.activities.last! {
                            width = 0 // last item
                        } else {
                            width -= d.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: {d in
                        let result = height
                        if activity == self.activities.last! {
                            height = 0 // last item
                        }
                        return result
                    })
            }
        }
    }

    func item(for text: String) -> some View {
        Label(text, image: "plus")
            .profileCapsuleStyle()
            .if(!isSuggestion) { view in
                view.labelStyle(.titleOnly)
            }
    }
}

#Preview {
    WrappedList(activities: ["Read New Testament", "Practice", "Pray everyday this week", "Worship", "Journal for 14 days", "Pray for 30 days", "Learn about love"])
}
