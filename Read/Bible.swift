//
//  Bible.swift
//  tbb
//
//  Created by Mary Etefia on 11/22/23.
//  Copyright © 2023 Study Aloud. All rights reserved.
//

import FirebaseFirestore
import SwiftUI

enum Highlight: CaseIterable {
    typealias RawValue = Color
    
    case cyan
    case green
    case pink
    case yellow
    
    init?(rawValue: Color) {
        switch rawValue {
        case .cyan: self = .cyan
        case .green: self = .green
        case .pink: self = .pink
        case .yellow: self = .yellow
        default: return nil
        }
    }
    
    var rawValue: Color {
        switch self {
        case .cyan: return .cyan
        case .green: return .green
        case .pink: return .pink
        case .yellow: return .yellow
        }
    }
}

// TODO: Log errors instead of printing them
struct Bible: View {
    let verseReference: Binding<VerseReference>
    let verses: [String]
    
    static let firestore = Firestore.firestore()
    static let collectionPath = "users/\(UserManager.shared.email)/verses"
    
    @State private var presentToolbox = false
    @State private var presentToolboxOptions = false
    @State private var highlightByVerseNumber: [Int: Color] = [:]
    
    @State private var presentDrawer = false
    
    // Finds all verses within users/user/verses that contain "book-chapter-", save their verse numbers to highlightByVerseNumber dictionary.
    func subscribe() {
        Self.firestore.collection(Self.collectionPath).addSnapshotListener({ documentSnapshot, error in
            if let versesSnapshot = documentSnapshot?.documents {
                for verse in versesSnapshot {
                    let documentID = verse.documentID
                    if documentID.contains("\(verseReference.book.wrappedValue)-\(verseReference.chapter.wrappedValue)") {
                        if let highlight = verse.data()["highlight"] as? String,
                           let verseNumberString = documentID.split(separator: "-").last,
                           let verseNumber = Int(verseNumberString) {
                            if let highlightQuery = Highlight.allCases.first(where: { $0.rawValue.description == highlight }) {
                                self.highlightByVerseNumber[verseNumber] = highlightQuery.rawValue.opacity(0.5)
                            } else if highlight.isEmpty {
                                self.highlightByVerseNumber[verseNumber] = nil
                            }
                        }
                    }
                }
            }
        })
    }

    var body: some View {
        ZStack(alignment: .trailing) {
            ScrollViewReader { proxy in
                List(Array(verses.enumerated()), id: \.offset) { index, verse in
                    VStack {
                        if presentToolboxOptions && (verseReference.verse.wrappedValue  == index + 1) {
                            BibleToolbox(id: "\(verseReference.book.wrappedValue)-\(verseReference.chapter.wrappedValue)-\(index+1)", verse: verse)
                                .padding(.bottom, 10.0)
                        }
                        Button(action: {
                            // Decide whether to present the toolbox button and the peer content drawer
                            verseReference.verse.wrappedValue = index + 1

                            presentDrawer.toggle()
                            presentToolbox.toggle()
                            if !presentToolbox { presentToolboxOptions = false }
                        }, label: {
                            HStack(alignment: .firstTextBaseline) {
                                Text("\(index + 1)  \(verse)")
                                    .underline(presentToolbox && (verseReference.verse.wrappedValue == index + 1))
                                    .background(highlightByVerseNumber[index+1])
                            }
                        })
                        .buttonStyle(PlainButtonStyle())
                    }
                    .foregroundStyle(Color(.appBlack))
                    .listRowSeparator(.hidden, edges: .all)
                    .id(index)
                }
                .listStyle(.plain)
                .sheet(isPresented: $presentDrawer, content: {
                    ScrollView([]) {
                        PeerDrawer(verseReference: verseReference.wrappedValue)
                            .padding(.vertical)
                    }
                    .ignoresSafeArea()
                    .presentationDetents([.fraction(0.15), .fraction(0.50)])
                })
                .onAppear {
                    subscribe()
                    proxy.scrollTo(verseReference.verse.wrappedValue - 1, anchor: .top)
                }
            }
            
            if presentToolbox {
                Button(action: {
                    presentToolboxOptions.toggle()
                }, label: {
                    HStack {
                        Image(.add)
                            .padding(.leading)
                        Spacer()
                    }
                    .background(RoundedRectangle(cornerRadius: 15.0).foregroundStyle(Color(.appOrange)))
                    .clipShape(RoundedRectangle(cornerRadius: 15.0))
                    .frame(width: 75)
                })
                .padding(.horizontal, -25.0)
                .buttonStyle(PlainButtonStyle())
            }
        }
    }

    struct BibleToolbox: View {
        // Saved as book-chapter-verse in database
        let id: String
        let verse: String
        
        let highlights: [Color] = [.yellow, .pink, .green, .cyan]
        
        // "Geneses 1:1"
        var reference: String {
            let splitRef = id.split(separator: "-")
            return "\(splitRef[0]) \(splitRef[1]):\(splitRef[2])"
        }

        @State private var highlight: Color?
        @State private var isBookmarked = false
        @State private var openJournal = false
        
        func setState() async {
            do {
                let ref = try await firestore.collection(collectionPath).document(id).getDocument()
                if let verse = ref.data() {
                    if let highlightQuery = Highlight.allCases.first(where: { $0.rawValue.description == verse["highlight"] as? String }) {
                        highlight = highlightQuery.rawValue
                    }
                    if let bookmarkQuery = verse["isBookmarked"] as? Bool {
                        isBookmarked = bookmarkQuery
                    }
                }
            } catch(let error) {
                print(error)
            }
        }
        
        func deleteVerseIfNeeded() async {
            if !isBookmarked && highlight == nil {
                do {
                    try await firestore.collection(collectionPath).document(id).delete()
                } catch(let error) {
                    print(error)
                }
            }
        }
        
        var body: some View {
            HStack(alignment: .center, spacing: 15.0) {
                // MARK: Highlight Buttons
                ForEach(highlights, id: \.self) { highlight in
                    Button(action: {
                        self.highlight = self.highlight != highlight ? highlight : nil

                        firestore.collection(collectionPath).document(id)
                            .setData(["highlight": self.highlight == nil ? "" : highlight.description], merge: true)
                        
                        // delete the whole verse if its neither bookmarked or highlighted
                        Task {
                            await deleteVerseIfNeeded()
                        }
                    }, label: {
                        Circle()
                            .frame(width: 22, height: 22)
                            .foregroundColor(highlight.opacity(0.5))
                    })
                    .buttonStyle(PlainButtonStyle())
                }
                
                Divider()
                    .frame(height: 22)
                
                // MARK: New Note Button
                Button(action: {
                    openJournal = true
                }, label: {
                    Image(.journalToolbox)
                })
                .buttonStyle(PlainButtonStyle())
                
                // MARK: Bookmark Button
                Button(action: {
                    isBookmarked.toggle()
                    
                    firestore.collection(collectionPath).document(id)
                        .setData(["isBookmarked": isBookmarked], merge: true)
                    
                    // delete the whole verse if its neither bookmarked or highlighted
                    Task {
                        await deleteVerseIfNeeded()
                    }
                }, label: {
                    Image(isBookmarked ? .bookmarkFill : .bookmark)
                        .foregroundStyle(Color(.appBlack))
                })
                .buttonStyle(PlainButtonStyle())
                
                // MARK: Share Button
                ShareLink(item: "The Bible Buddie App: \(reference)\n\(verse)", label: { Image(.share) })
                .buttonStyle(PlainButtonStyle())
            }
            .padding(9.0)
            .background(
                RoundedRectangle(cornerRadius: 20.0, style: .circular)
                    .shadow(radius: 3)
                    .frame(width: 275)
                    .foregroundColor(Color(.appEggWhite))
                    
            )
            .task { await setState() }
            .navigationDestination(isPresented: $openJournal, destination: { Scripture(reference: reference) })
        }
    }
}

#Preview {
    Bible.BibleToolbox(id: "", verse: "")
}

