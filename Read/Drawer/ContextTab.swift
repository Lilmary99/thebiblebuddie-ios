//
//  PillTab.swift
//  tbb
//
//  Created by Mary Etefia on 1/5/24.
//  Copyright © 2024 Study Aloud. All rights reserved.
//

import SwiftUI

struct ContextTab: View {
    let verseReference: VerseReference
    let content: [String: [String: String]] = ["Character": ["Job": "Good guy", "Ruth": "Strong lady"], "Tradition": ["Mazeltov": "Fun thing to say"]] // [Pill: [Title: Description]]
    
    let pills: [String]
    @State private var selectedPill: String
    @State private var selectedTitle: String?
    @State private var presentContent: Bool = false

    init(verseReference: VerseReference) {
        self.verseReference = verseReference
        self.pills = Array(content.keys)
        _selectedPill = State(initialValue: self.pills.first ?? "")
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                ForEach(pills, id: \.self) { pill in
                    Button(action: {
                        selectedPill = pill
                        presentContent = false
                    }, label: {
                        DrawerPill(title: pill, selection: $selectedPill)
                    })
                }
            }
            
            if presentContent {
                HStack(alignment: .top) {
                    Button(action: {
                        presentContent.toggle()
                    }, label: {
                        Image(.leftChevron)
                    })
                    
                    VStack(alignment: .leading) {
                        Text(selectedTitle ?? "")
                            .fontWeight(.semibold)
                        Text(content[selectedPill]?[selectedTitle ?? ""] ?? "")
                            .padding(.top)
                    }
                }
                .padding()
            } else if let titles = content[selectedPill]?.keys {
                List(Array(titles), id: \.self) { title in
                    Button(action: {
                        selectedTitle = title
                        presentContent.toggle()
                    }, label: {
                        HStack(alignment: .center) {
                            Text(title)
                                .fontWeight(.semibold)
                            Spacer()
                            Text(content[selectedPill]?[title]?.prefix(25) ?? "")
                                .lineLimit(2)
                            Spacer()
                            Spacer()
                            Image(.chevron)
                        }
                    })
                }
                .listStyle(.inset)
            }
        }
//        .padding()
    }
}

#Preview {
    ContextTab(verseReference: VerseReference(book: "Genesis", chapter: 21, verse: 3, translation: "KJV"))
}
