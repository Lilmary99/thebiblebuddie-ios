//
//  BibleQuery.swift
//  tbb
//
//  Created by Mary Etefia on 11/24/23.
//  Copyright © 2023 Study Aloud. All rights reserved.
//

import FirebaseCore
import FirebaseFirestore
import Foundation

// To query verses by using translation, book and chapter
@MainActor
class BibleQuery: ObservableObject {
    var translation: String = "KJV" {
        didSet { Task { await queryVerses() } }
    }
    var book: String = "Genesis"
    var chapter: String = "1"
    
    @Published var verses: [String] = []
    
    let firestore = Firestore.firestore()
    
    init() {
        Task { await queryVerses() }
    }
    
    public func queryVerses() async {
        do {
            let snapshot = try await firestore.collection("translations").document(translation.lowercased()).collection(book).document(chapter).getDocument()
            if let verses = snapshot.get("verses") as? [String] {
                DispatchQueue.main.async {
                    self.verses = verses
                }
            }
        } catch(let error) {
            // TODO: Return alert message somehow? Log error and crash the app?
            print(error)
        }
    }
}
