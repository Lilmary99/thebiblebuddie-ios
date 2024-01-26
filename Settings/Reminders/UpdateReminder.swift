//
//  CreateReminder.swift
//  tbb
//
//  Created by Mary Etefia on 10/15/23.
//  Copyright © 2023 Study Aloud. All rights reserved.
//

import FirebaseFirestore
import SwiftUI

// TODO: This page makes app crash for some reason
struct UpdateReminder: View {
    var documentID: String?
    @Environment(\.presentationMode) var mode

    @Environment(\.dismiss) private var dismiss
    @State var date: Date
    @State var label: String
    @State var selectedDays: [String]
    
    let days: [String] = Calendar.current.weekdaySymbols
    
    init(reminder: Reminder? = nil) {
        
        if let reminder = reminder {
            documentID = reminder.id
            // This reminder already exists
            _date = State(initialValue: reminder.date)
            _label = State(initialValue: reminder.label)
            _selectedDays = State(initialValue: reminder.selectedDays)
        } else {
            // This is a new reminder
            _date = State(initialValue: .now)
            _label = State(initialValue: "")
            _selectedDays = State(initialValue: [])
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20.0) {
                DatePicker("Time", selection: $date, displayedComponents: .hourAndMinute)
                    .fontWeight(.semibold)
                
                Text("Label")
                    .fontWeight(.semibold)
                ResponseField(hint: "Ex. Time to study", response: $label)
                
                Text("Repeat")
                    .fontWeight(.semibold)
                HStack {
                    ForEach(days, id: \.self) { day in
                        Button(action: {
                            if selectedDays.contains(day) {
                                selectedDays.removeAll(where: { $0 == day })
                            } else {
                                selectedDays.append(day)
                            }
                        }, label: {
                            ZStack(alignment: .center) {
                                Circle()
                                    .foregroundStyle(selectedDays.contains(day) ? Color(.appBlue) : Color(.appGray))
                                Text(day.prefix(1))
                                    .foregroundStyle(Color(.appBlack))
                            }
                        })
                        
                    }
                }
                
                Spacer()
            }
            .padding()
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color(.appEggWhite), for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    BackButton(title: "Create Reminder", dismissAction: dismiss)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        let reminderID: String
                        
                        // If the user is editing an existing reminder, the doc ID (and document) already exists. Otherwise, create a new document
                        if let documentID = self.documentID {
                            reminderID = documentID
                            Firestore.firestore().collection("users/\(UserManager.shared.email)/reminders").document(documentID)
                                .setData(["date": date, "label": label, "selectedDays": selectedDays, "isEnabled": true])
                        } else {
                            reminderID = Firestore.firestore().collection("users/\(UserManager.shared.email)/reminders").document().documentID
                            Firestore.firestore().collection("users/\(UserManager.shared.email)/reminders").document(reminderID)
                                .setData(["date": date, "label": label, "selectedDays": selectedDays, "isEnabled": true])
                        }
                        
                        subscribeToReminder(reminderID: reminderID, date: date, label: label, selectedDays: selectedDays)
                        dismiss()
                    } label: {
                        Image(.checkmark)
                            .foregroundColor(Color(.appOrange))
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    UpdateReminder()
}
