//
//  Insight.swift
//  tbb
//
//  Created by Mary Etefia on 1/5/24.
//  Copyright © 2024 Study Aloud. All rights reserved.
//

import SwiftUI

struct InsightTab: View {
    // Only one verse reference in this tab, since the Drawer is only shown after tapping a specific verse to begin with
    let verseReference: VerseReference
    let insight: String = "Just a great verse man."
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(verseReference.description)
                .fontWeight(.semibold)
            Text(insight)
            Spacer()
        }
    }
}

#Preview {
    InsightTab(verseReference: VerseReference(book: "Genesis", chapter: 21, verse: 3, translation: "KJV"))
}
