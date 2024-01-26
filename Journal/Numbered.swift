//
//  Numbered.swift
//  tbb
//
//  Created by Mary Etefia on 11/21/23.
//  Copyright © 2023 Study Aloud. All rights reserved.
//

import FirebaseFirestore
import SwiftUI

struct Numbered: View {
    let type: JournalTemplate
    var documentID: String?

    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var points: [String] = [""]
    
    func queryNumberedNote() async {
        if let documentID = documentID {
            do {
                let note = try await Firestore.firestore().collection("users/\(UserManager.shared.email)/journal").document(documentID).getDocument()
                if let title = note.get("title") as? String, let points = note.get("points") as? [String] {
                    self.title = title
                    self.points = points
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
                    TextField(type == .gratitude ? "Gratitude" : "Life Lessons", text: $title)
                        .font(.title)
                        .fontWeight(.semibold)
                    Spacer(minLength: 20.0)
                    Text(type == .gratitude ? "Things I am grateful for today:" : "Things that I have learned today:")
                    Spacer(minLength: 20.0)
                    
                    VStack(alignment: .leading, spacing: 1.0) {
                        ForEach(Array(points.enumerated()), id: \.offset) { index, point in
                            JournalRow(type: type, height: narrowHeight, field: "\(index + 1).", value: $points[index])
                            Divider()
                        }
                    }
                    .background(Rectangle().stroke(Color(.appGray), lineWidth: 1.0))
                    
                    AddButton(points: $points)
                        .padding(.top)
                }
                .task { await queryNumberedNote() }
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
                    .setData(["type": type.rawValue, "date": FieldValue.serverTimestamp(), "title": title, "points": points, "preview": points[0].prefix(15)])
            } else {
                Firestore.firestore().collection("users/\(UserManager.shared.email)/journal").document()
                    .setData(["type": type.rawValue, "date": FieldValue.serverTimestamp(), "title": title, "points": points, "preview": points[0].prefix(15)])
            }
            dismiss()
        })
    }
}

#Preview {
    Numbered(type: .gratitude)
}
