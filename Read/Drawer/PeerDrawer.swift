//
//  PeerDrawer.swift
//  tbb
//
//  Created by Mary Etefia on 11/22/23.
//  Copyright © 2023 Study Aloud. All rights reserved.
//

import SwiftUI

enum TabName: String, CaseIterable {
    case summary = "Summary"
    case insight = "Insight"
    case context = "Context"
    case translations = "Translations"
}

// TODO: Each tab view will query from the database respectively in their own file
struct PeerDrawer: View {
    let verseReference: VerseReference
    
    let drawerTabs = TabName.allCases
    @State private var selection: TabName = .summary

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .firstTextBaseline) {
                ForEach(drawerTabs, id: \.self) { tab in
                    DrawerTab(tab: tab, selection: $selection)
                    Spacer()
                }
            }
            
            Divider()
                .padding(.top, -11)
            
            switch selection {
            case .summary:
                SummaryTab(verseReference: verseReference)
                    .frame(height: 200)
            case .insight:
                InsightTab(verseReference: verseReference)
                    .frame(height: 200)
            case .context:
                ContextTab(verseReference: verseReference)
                    .frame(height: 200)
            case .translations:
                TranslationsTab(verseReference: verseReference)
                    .frame(height: 200)
            }
        }
        .padding()
    }
}

struct DrawerTab: View {
    let tab: TabName
    var selection: Binding<TabName>?
    
    var isSelected: Bool {
        get {
            selection?.wrappedValue == tab
        }
    }
    
    var body: some View {
        Button(action: {
            withAnimation(.none) {
                selection?.wrappedValue = tab
            }
        }, label: {
            VStack(spacing: 5) {
                Text(tab.rawValue)
                    .lineLimit(1)
                    .foregroundStyle(Color(isSelected ? .appBlack : .appDarkGray))
                    .fontWeight(.semibold)
                
                if isSelected {
                    Divider()
                        .frame(height: 3)
                        .overlay(Color(.appOrange))
                }
            }
        })
        .fixedSize()
    }
}

#Preview {
    PeerDrawer(verseReference: VerseReference(book: "Genesis", chapter: 21, verse: 3, translation: "KJV"))
}
