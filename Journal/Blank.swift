//
//  Blank.swift
//  tbb
//
//  Created by Mary Etefia on 11/15/23.
//  Copyright © 2023 Study Aloud. All rights reserved.
//

import FirebaseFirestore
import SwiftUI

struct Blank: View {
    var documentID: String?
    
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var bodyText = ""
    
    func queryBlankNote() async {
        if let documentID = documentID {
            do {
                let note = try await Firestore.firestore().collection("users/\(UserManager.shared.email)/journal").document(documentID).getDocument()
                if let title = note.get("title") as? String, let body = note.get("body") as? String {
                    self.title = title
                    self.bodyText = body
                }
            } catch(let error) {
                print(error)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20.0) {
                    TextField("Title", text: $title)
                        .font(.title)
                        .fontWeight(.semibold)
                    
                    CustomTextEditor(placeholder: "Type here", text: $bodyText)
                }
                .task { await queryBlankNote() }
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
                    .setData(["type": JournalTemplate.blank.rawValue, "date": FieldValue.serverTimestamp(), "title": title, "body": bodyText, "preview": bodyText.prefix(15)])
            } else {
                Firestore.firestore().collection("users/\(UserManager.shared.email)/journal").document()
                    .setData(["type": JournalTemplate.blank.rawValue, "date": FieldValue.serverTimestamp(), "title": title, "body": bodyText, "preview": bodyText.prefix(15)])
            }
            dismiss()
        })
    }
}

#Preview {
    Blank()
}
