//
//  Books.swift
//  tbb
//
//  Created by Mary Etefia on 11/22/23.
//  Copyright © 2023 Study Aloud. All rights reserved.
//

import SwiftUI

struct Books: View {
    let filter: Binding<BibleFilter>
    let verseReference: Binding<VerseReference>
    
    let books: [String] = ["Genesis", "Exodus", "Leviticus", "Numbers", "Deuteronomy", "Joshua", "Judges", "Ruth", "1 Samuel", "2 Samuel", "1 Kings", "2 Kings", "1 Chronicles", "2 Chronicles", "Ezra", "Nehemiah", "Esther", "Job", "Psalms", "Proverbs", "Ecclesiastes", "Songs of Solomon", "Isaiah", "Jeremiah", "Lamentations", "Ezekiel", "Daniel", "Hosea", "Joel", "Amos", "Obadiah", "Jonah", "Micah", "Nahum", "Habakkuk", "Haggai", "Zechariah", "Malachi", "Matthew", "Mark", "Luke", "John", "Acts", "Romans", "1 Corinthians", "2 Corinthians", "Galatians", "Ephesians", "Philippians", "Colossians", "1 Thessalonians", "2 Thessalonians", "1 Timothy", "2 Timothy", "Titus", "Philemon", "Hebrews", "James", "1 Peter", "2 Peter", "1 John", "2 John", "3 John", "Jude", "Revelation"];
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Select a book.")
                
                Spacer()
                
                Button(action: {
                    filter.wrappedValue = .bible
                }, label: {
                    Text("Cancel")
                })
            }
            .foregroundStyle(Color(.appDarkGray))
            
            Divider()
            
            List(books, id: \.self) { book in
                HStack {
                    BibleCircle()
                    
                    Button(action: {
                        verseReference.book.wrappedValue = book
                        filter.wrappedValue = .chapters
                    }, label: {
                        Text(book)
                            .foregroundStyle(Color(.appBlack))
                    })
                }
            }
            .listStyle(.plain)
        }
        .padding()
    }
}
