//
//  SummaryTab.swift
//  tbb
//
//  Created by Mary Etefia on 1/5/24.
//  Copyright © 2024 Study Aloud. All rights reserved.
//

import SwiftUI

struct SummaryTab: View {
    let verseReference: VerseReference
    let content: [String: String] = ["Purpose": "To spread the gospel", "Audience": "Ppl of the world", "Tradition": "Bar mitzfah"] // [Pill: Summary]
    
    let pills: [String]
    @State private var selection: String
    
    init(verseReference: VerseReference) {
        self.verseReference = verseReference
        self.pills = Array(content.keys)
        _selection = State(initialValue: self.pills.first ?? "")
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                ForEach(pills, id: \.self) { pill in
                    Button(action: {
                        selection = pill
                    }, label: {
                        DrawerPill(title: pill, selection: $selection)
                    })
                }
            }
            Text(content[selection] ?? "")
                .padding()
            Spacer()
        }
    }
}

#Preview {
    SummaryTab(verseReference: VerseReference(book: "Genesis", chapter: 21, verse: 3, translation: "KJV"))
}
