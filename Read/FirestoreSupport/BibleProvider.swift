//
//  BibleProvider.swift
//  tbb
//
//  Created by Mary Etefia on 11/24/23.
//  Copyright © 2023 Study Aloud. All rights reserved.
//

import FirebaseCore
import FirebaseFirestore
import Foundation

/// To query numeric representations for chapters, and verses available to the user based off translation
class BibleProvider: ObservableObject {
    let book: String
    let chapter: String?
    let translation: String = "KJV"
    
    @Published var numerics: [String] = []
    
    let firestore = Firestore.firestore()
    
    init(book: String, chapter: String?) {
        self.book = book
        self.chapter = chapter
     
        Task {
            if let chapter = chapter {
                await getVerses(for: book, and: chapter)
            } else {
                await getChapters(for: book)
            }
        }
    }

    // TODO: Cache the following results?
    
    public func getChapters(for book: String) async {
        do {
            let snapshot = try await firestore.collection("translations").document(translation.lowercased()).collection(book).getDocuments()
            DispatchQueue.main.async {
                self.numerics = (1...snapshot.documents.count).map({ String($0) })
            }
        } catch(let error) {
            print(error)
        }
    }
    
    public func getVerses(for book: String, and chapter: String) async {
        do {
            let snapshot = try await firestore.collection("translations").document(translation.lowercased()).collection(book).document(chapter).getDocument()
            if let verses = snapshot.get("verses") as? [String] {
                DispatchQueue.main.async {
                    self.numerics = (1...verses.count).map({ String($0) })
                }
            }
        } catch(let error) {
            print(error)
        }
    }
}

