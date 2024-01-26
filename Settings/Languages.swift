//
//  Languages.swift
//  tbb
//
//  Created by Mary Etefia on 10/15/23.
//  Copyright © 2023 Study Aloud. All rights reserved.
//

import SwiftUI

struct Languages: View {
    // TODO: Replace with database list
    
    let options: [(locale: String, language: String)] = [("en", "English"), ("es", "Spanish"), ("fr", "French")]
    
    @Environment(\.dismiss) private var dismiss
    @State var selectedLocale: String = "en"
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Text("Choose a language.")
                List {
                    ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                        LanguageLink(option: option, selectedLocale: $selectedLocale)
                    }
                }
                .listStyle(.plain)
            }
            .padding()
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color(.appEggWhite), for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    BackButton(title: "Languages", dismissAction: dismiss)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        // TODO: Apply the following line to the actual app.
        .environment(\.locale, .init(identifier: selectedLocale))
    }
}

struct LanguageLink: View {
    let option: (locale: String, language: String)
    let selectedLocale: Binding<String>
    
    var body: some View {
        HStack {
            Text(option.language)
            Spacer()
            if selectedLocale.wrappedValue == option.locale {
                Image("checkmark")
                    .foregroundColor(Color(.appOrange))
            }
        }
        .onTapGesture {
            selectedLocale.wrappedValue = option.locale
        }
    }
}

#Preview {
    Languages()
}
