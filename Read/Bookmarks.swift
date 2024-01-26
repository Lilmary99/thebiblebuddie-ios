//
//  Bookmarks.swift
//  tbb
//
//  Created by Mary Etefia on 12/22/23.
//  Copyright © 2023 Study Aloud. All rights reserved.
//

import FirebaseCore
import FirebaseFirestore
import SwiftUI

struct Bookmarks: View {
    // For updates to Read()
    let filter: Binding<BibleFilter>
    let verseReferenceCaptured: Binding<VerseReference>
    
    let firestore = Firestore.firestore()
    let versesPath = "users/\(UserManager.shared.email)/verses"
    
    @State private var verseByReference: [String: String] = [:]
    
    func queryBookmarks() async {
        do {
            let referenceQuery = try await firestore.collection(versesPath).getDocuments().documents
            for document in referenceQuery where document.get("isBookmarked") as? Bool == true {
                let bookmark = document.documentID
                let bookmarkComponents = bookmark.split(separator: "-")
                let chapter = try await firestore.collection("translations/kjv/\(bookmarkComponents[0])").document("\(bookmarkComponents[1])").getDocument()
                if let verses = chapter.get("verses") as? [String], let verseNum = Int(bookmarkComponents[2]) {
                    verseByReference["\(bookmarkComponents[0]) \(bookmarkComponents[1]): \(bookmarkComponents[2])"] = verses[verseNum]
                }
            }
        } catch(let error) {
            print(error)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Bookmarks")
                .font(.title2)
                .fontWeight(.semibold)
            List(Array(verseByReference.keys.enumerated()), id: \.offset) { index, key in
                HStack {
                    VStack(alignment: .leading, spacing: 10.0) {
                        Text(key)
                            .fontWeight(.semibold)
                        Text(verseByReference[key] ?? "")
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        var keyToRead = key
                        keyToRead.removeAll(where: { $0 == ":" })
                        let parsedVerseReferenece = keyToRead.split(whereSeparator: { $0.isWhitespace })
                        
                        verseReferenceCaptured.book.wrappedValue = String(parsedVerseReferenece[0])
                        verseReferenceCaptured.chapter.wrappedValue = Int(String(parsedVerseReferenece[1])) ?? 1
                        verseReferenceCaptured.verse.wrappedValue = Int(String(parsedVerseReferenece[2])) ?? 1
                        
                        filter.wrappedValue = .bible // Pops back to Read()
                    }, label: {
                        Image(.chevron)
                    })
                }
                .listRowSeparator(index == 0 ? .hidden : .visible, edges: .top)
            }
            .listStyle(.plain)
        }
        .padding()
        .task { await queryBookmarks() }
    }
}
