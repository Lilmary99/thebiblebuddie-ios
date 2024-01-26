//
//  Scripture.swift
//  tbb
//
//  Created by Mary Etefia on 11/21/23.
//  Copyright © 2023 Study Aloud. All rights reserved.
//

import FirebaseFirestore
import SwiftUI

struct Scripture: View {
    var documentID: String?
    var reference: String?

    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var scriptures = [""]
    @State private var revelation = ""
    
    func queryScriptureNote() async {
        if let documentID = documentID {
            do {
                let note = try await Firestore.firestore().collection("users/\(UserManager.shared.email)/journal").document(documentID).getDocument()
                if let title = note.get("title") as? String, let scriptures = note.get("scriptures") as? [String], let revelation = note.get("revelation") as? String {
                    self.title = title
                    self.scriptures = scriptures
                    self.revelation = revelation
                }
            } catch(let error) {
                print(error)
            }
        } else if let reference = reference {
            self.scriptures = [reference]
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 1.0) {
                    TextField("Scripture Notes", text: $title)
                        .font(.title)
                        .fontWeight(.semibold)
                    Spacer(minLength: 20.0)
                    
                    VStack(alignment: .leading, spacing: 1.0) {
                        // TODO: Add Bookmarks button to this row
                        JournalRow(type: .sermons, height: narrowHeight, field: "Scripture", value: $scriptures[0])
                        Divider()
                        JournalRow(type: .sermons, height: 400.0, field: "My Revelation", value: $revelation)
                    }
                    .background(Rectangle().stroke(Color(.appGray), lineWidth: 1.0))
                }
                .task { await queryScriptureNote() }
            }
            .padding()
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color(.appEggWhite), for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    BackButton(title: "Journal", dismissAction: dismiss)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        notificationCenter.post(name: .editingComplete, object: nil)
                    } label: {
                        Image(.checkmark)
                            .foregroundColor(Color(.appOrange))
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onReceive(notificationCenter.publisher(for: .editingComplete), perform: { _ in
            // If the user is editing an existing note, the doc ID (and document already exists. Otherwise, create a new document
            if let documentID = self.documentID {
                Firestore.firestore().collection("users/\(UserManager.shared.email)/journal").document(documentID)
                    .setData(["type": JournalTemplate.scripture.rawValue, "date": FieldValue.serverTimestamp(), "title": title, "scriptures": scriptures, "revelation": revelation, "preview": scriptures[0].prefix(15)])
            } else {
                Firestore.firestore().collection("users/\(UserManager.shared.email)/journal").document()
                    .setData(["type": JournalTemplate.scripture.rawValue, "date": FieldValue.serverTimestamp(), "title": title, "scriptures": scriptures, "revelation": revelation, "preview": scriptures[0].prefix(15)])
            }
            dismiss()
        })
    }
}

#Preview {
    Scripture()
}

