//
//  TranslationsTab.swift
//  tbb
//
//  Created by Mary Etefia on 1/5/24.
//  Copyright © 2024 Study Aloud. All rights reserved.
//

import SwiftUI

struct TranslationsTab: View {    
    let verseReference: VerseReference
    let translations: [String] = ["ASV", "ESV", "KJV", "NIV", "NLT"]

    var body: some View {
        VStack(alignment: .leading) {
            Text("Hello, World!")
            Spacer()
        }
    }
}

#Preview {
    TranslationsTab(verseReference: VerseReference(book: "Genesis", chapter: 21, verse: 3, translation: "KJV"))
}
