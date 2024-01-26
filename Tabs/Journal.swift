//
//  Journal.swift
//  tbb
//
//  Created by Mary Etefia on 9/10/23.
//  Copyright © 2023 Study Aloud. All rights reserved.
//

import FirebaseFirestore
import SwiftUI

struct Note {
    let id: String
    let type: JournalTemplate
    let date: Date
    let title: String
    let preview: String
}

struct Journal: View {
    @State private var notes: [Note] = []
    @State private var openNote = false
    @State private var navigationPayload: (type: JournalTemplate, id: String)?

    func subscribe() {
        Firestore.firestore().collection("users/\(UserManager.shared.email)/journal").addSnapshotListener({ snapshot, error in
            var result: [Note] = []
            if let snapshot = snapshot {
                for note in snapshot.documents {
                    if let type = note.get("type") as? String,
                       let template = JournalTemplate(rawValue: type),
                       let date = note.get("date") as? Timestamp,
                       let title = note.get("title") as? String,
                       let preview = note.get("preview") as? String {
                        let formattedNote = Note(id: note.documentID,
                                                 type: template,
                                                 date: date.dateValue(),
                                                 title: title,
                                                 preview: preview)
                        
                        result.append(formattedNote)
                    }
                }
            }
            
            notes = result.sorted(by: { $0.date > $1.date })
        })
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if notes.isEmpty {
                    Text("You have no journal entries.")
                } else {
                    List(Array(notes.enumerated()), id: \.offset) { index, note in
                        Button(action: { openNote = true; navigationPayload = (note.type, note.id) }, label: {
                            HStack {
                                JournalItem(date: note.date, titleByDescription: (note.title, note.preview))
                                Spacer()
                            }
                        })
                        .padding()
                        .swipeActions(edge: .leading) {
                            Button {
                                Firestore.firestore().collection("users/\(UserManager.shared.email)/journal").document(note.id).delete()
                                notes.removeAll(where: { $0.id == note.id })
                            } label: {
                                Image("trash-fill")
                                    .foregroundStyle(Color(.appWhite))
                            }
                            .tint(Color(.appRed))
                        }
                        .listRowSeparator(index == 0 ? .hidden : .visible, edges: .top)
                    }
                    .listStyle(.plain)
                }
            }
            .onAppear { subscribe() }
            .navigationDestination(isPresented: $openNote) {
                if let navigationPayload = self.navigationPayload {
                    switch navigationPayload.type {
                    case .blank:
                        Blank(documentID: navigationPayload.id)
                    case .sermons:
                        Sermon(documentID: navigationPayload.id)
                    case .gratitude:
                        Numbered(type: .gratitude, documentID: navigationPayload.id)
                    case .lifeLessons:
                        Numbered(type: .lifeLessons, documentID: navigationPayload.id)
                    case .scripture:
                        Scripture(documentID: navigationPayload.id)
                    }
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color(.appEggWhite), for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Image("journal-toolbar")
                        .foregroundStyle(Color(.appOrange))
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Text("Journal")
                        .font(.title)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: TemplateChooser(),
                                   label: {
                        Image("compose")
                            .foregroundColor(Color(.appOrange))
                    })
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct JournalItem: View {
    let date: Date
    let titleByDescription: (String, String)
    let dateFormatter = DateFormatter()
    
    init(date: Date, titleByDescription:(String, String)) {
        self.date = date
        self.titleByDescription = titleByDescription
    
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10.0) {
            Text(titleByDescription.0)
                .fontWeight(.semibold)
                .foregroundColor(Color(.appBlack))
            HStack {
                Text(dateFormatter.string(from: date))
                Text(titleByDescription.1.prefix(15))
            }
            .foregroundColor(Color(.appDarkGray))
        }
        .lineLimit(1)
    }
}

#Preview {
    Journal()
}
