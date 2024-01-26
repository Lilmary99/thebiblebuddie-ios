//
//  Read.swift
//  tbb
//
//  Created by Mary Etefia on 9/10/23.
//  Copyright © 2023 Study Aloud. All rights reserved.
//

import SwiftUI

enum BibleFilter: Int {
    case bible = 0
    case books
    case bookmarks
    case chapters
    case verses
    case translations
}

struct Reading: View {
    let verseReference: Binding<VerseReference>
    let verseReferenceCaptured: Binding<VerseReference>
    let verses: Binding<[String]>
    let filter: Binding<BibleFilter>
    
    @ViewBuilder
    var body: some View {
        switch filter.wrappedValue {
        case .bible:
            Bible(verseReference: verseReferenceCaptured, verses: verses.wrappedValue)
        case .books:
            Books(filter: filter, verseReference: verseReferenceCaptured)
        case .chapters:
            NumberedButtons(filter: filter, forChapters: true, verseReference: verseReference, verseReferenceCaptured: verseReferenceCaptured)
        case .verses:
            NumberedButtons(filter: filter, forChapters: false, verseReference: verseReference, verseReferenceCaptured: verseReferenceCaptured)
        case .translations:
            Translations(verseReference: verseReferenceCaptured)
        case .bookmarks:
            Bookmarks(filter: filter, verseReferenceCaptured: verseReferenceCaptured)
        }
    }
}

struct Read: View {
    // Monitored across app via by Tabs(), set on change of verseReferenceCaptured.verse
    let verseReference: Binding<VerseReference>
    
    // Monitored by Read() only
    @State private var verseReferenceCaptured: VerseReference

    @State private var filter: BibleFilter = .bible
    @State private var verses: [String] = []
    @StateObject private var query: BibleQuery = BibleQuery()
    
    init(verseReference: Binding<VerseReference>) {
        self.verseReference = verseReference
        _verseReferenceCaptured = State(initialValue: verseReference.wrappedValue)
    }

    var body: some View {
        NavigationStack {
            Reading(verseReference: verseReference, verseReferenceCaptured: $verseReferenceCaptured, verses: $verses, filter: $filter)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarBackground(Color(.appEggWhite), for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        // Quiet Mode
                        Button(action: {
                            // TODO: Open Quiet Mode instructions
                        }, label: { Image(.quietMode).foregroundColor(Color(.appBlack)) })
                    }
                    
                    ToolbarItem(placement: .topBarLeading) {
                        HStack {
                            // Chapter Selection
                            Button("\(verseReferenceCaptured.book) \(verseReferenceCaptured.chapter)") {
                                if filter == .bible {
                                    filter = .books
                                }
                            }
                            .padding(2.0)
                            .foregroundColor(Color(.appBlack))
                            .background(
                                RoundedRectangle(cornerRadius: 25.0)
                                    .stroke(Color(.appGray), lineWidth: 1)
                                    .background(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 25.0))
                            )
                            
                            // Translation selection
                            Button(verseReferenceCaptured.translation) {
                                if filter == .bible {
                                    filter = .translations
                                }
                                
                                if filter == .translations {
                                    filter = .bible
                                }
                            }
                            .padding(2.0)
                            .foregroundColor(Color(.appBlack))
                            .background(
                                RoundedRectangle(cornerRadius: 25.0)
                                    .stroke(Color(.appGray), lineWidth: 1)
                                    .background(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 25.0))
                            )
                        }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        // Bookmarks
                        Button(action: {
                            if filter == .bible {
                                filter = .bookmarks
                            }
                            
                            if filter == .bookmarks {
                                filter = .bible
                            }
                        }, label: {
                            Image(filter == .bookmarks ? .bookmarkFill : .bookmark).foregroundColor(Color(.appBlack))
                        })
                    }
                }
        }
        .navigationBarBackButtonHidden(true)
        .onReceive(self.query.$verses, perform: { newVerses in
            verses = newVerses
        })
        .onChange(of: self.verseReferenceCaptured.book) { newBook in
            query.book = newBook
        }
        .onChange(of: self.verseReferenceCaptured.chapter) { newChapter in
            query.chapter = String(newChapter)
        }
        .onChange(of: self.verseReferenceCaptured.translation) { newTranslation in
            filter = .bible; query.translation = newTranslation
        }
        .onChange(of: self.filter) { [filter] newFilter in
            if ((filter == .verses && newFilter == .bible) || (filter == .bookmarks && newFilter == .bible)) {
                verseReference.wrappedValue = verseReferenceCaptured

                Task {
                    await self.query.queryVerses()
                }
            }
            
            if filter  == .books && newFilter == .chapters {
                verseReferenceCaptured.chapter = 1
            }
        }
    }
}
