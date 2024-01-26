//
//  Translations.swift
//  tbb
//
//  Created by Mary Etefia on 11/22/23.
//  Copyright © 2023 Study Aloud. All rights reserved.
//

import SwiftUI

struct Translations: View {
    let verseReference: Binding<VerseReference>

    let translations: [String] = ["ASV", "ESV", "KJV", "NIV", "NLT"]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Select a translation.")
                .foregroundStyle(Color(.appDarkGray))
            Divider()
            List(translations, id: \.self) { translation in
                Button(action: {
                    verseReference.translation.wrappedValue = translation
                }, label: {
                    Text(translation)
                        .foregroundStyle(Color(.appBlack))
                })
                
            }
            .listStyle(.plain)
        }
        .padding()
    }
}
