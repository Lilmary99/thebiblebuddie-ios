//
//  Sermon.swift
//  tbb
//
//  Created by Mary Etefia on 11/21/23.
//  Copyright © 2023 Study Aloud. All rights reserved.
//

import FirebaseFirestore
import SwiftUI

struct Sermon: View {
    var documentID: String?

    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var preacher = ""
    @State private var scripture = ""
    @State private var points: [String] = [""]
    @State private var contexts: [String] = [""]
    
    func querySermonNote() async {
        if let documentID = documentID {
            do {
                let note = try await Firestore.firestore().collection("users/\(UserManager.shared.email)/journal").document(documentID).getDocument()
                if let title = note.get("title") as? String, 
                    let preacher = note.get("preacher") as? String,
                   let scripture = note.get("scripture") as? String, 
                    let points = note.get("points") as? [String],
                   let contexts = note.get("contexts") as? [String] {
                    self.title = title
                    self.preacher = preacher
                    self.scripture = scripture
                    self.points = points
                    self.contexts = contexts
                }
            } catch(let error) {
                print(error)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 1.0) {
                    TextField("Sermon Title", text: $title)
                        .font(.title)
                        .fontWeight(.semibold)
                    Spacer(minLength: 20.0)
                    
                    VStack(alignment: .leading, spacing: 1.0) {
                        JournalRow(type: .sermons, height: narrowHeight, field: "Preacher", value: $preacher)
                        
                        Divider()
                        
                        JournalRow(type: .sermons, height: narrowHeight, field: "Scripture", value: $scripture)
                        
                        Divider()
                        ForEach(Array(points.enumerated()), id: \.offset) { index, point in
                            JournalRow(type: .sermons, height: narrowHeight, field: "Point \(index + 1)", value: $points[index])
                            Divider()
                            JournalRow(type: .sermons, height: broadHeight, field: "Context", value: $contexts[index])
                        }
                    }
                    .background(Rectangle().stroke(Color(.appGray), lineWidth: 1.0))
                    
                    AddButton(points: $points, contexts: $contexts)
                        .padding(.top)
                }
                .task { await querySermonNote() }
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
                    .setData(["type": JournalTemplate.sermons.rawValue, "date": FieldValue.serverTimestamp(), "title": title, "preacher": preacher, "scripture": scripture, "points": points, "contexts": contexts, "preview": points[0].prefix(15)])
            } else {
                Firestore.firestore().collection("users/\(UserManager.shared.email)/journal").document()
                    .setData(["type": JournalTemplate.sermons.rawValue, "date": FieldValue.serverTimestamp(), "title": title, "preacher": preacher, "scripture": scripture, "points": points, "contexts": contexts, "preview": points[0].prefix(15)])
            }
            dismiss()
        })
    }
}

#Preview {
    Sermon()
}
