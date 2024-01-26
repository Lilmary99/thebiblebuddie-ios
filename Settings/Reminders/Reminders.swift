//
//  Reminders.swift
//  tbb
//
//  Created by Mary Etefia on 10/15/23.
//  Copyright © 2023 Study Aloud. All rights reserved.
//

import FirebaseFirestore
import SwiftUI

struct Reminders: View {
    @Environment(\.dismiss) private var dismiss

    @State private var showReminder = false
    @State private var selectedReminder: Reminder?
    
    @State private var reminders: [Reminder] = []
    
    func subscribe() {
        Firestore.firestore().collection("users/\(UserManager.shared.email)/reminders").addSnapshotListener({ snapshot, error in
            var result: [Reminder] = []
            if let snapshot = snapshot {
                for reminder in snapshot.documents {
                    if let date = reminder.get("date") as? Timestamp,
                       let label = reminder.get("label") as? String,
                       let isEnabled = reminder.get("isEnabled") as? Bool,
                       let selectedDays = reminder.get("selectedDays") as? [String] {
                        let formattedReminder = Reminder(id: reminder.documentID, date: date.dateValue(), label: label, isEnabled: isEnabled, selectedDays: selectedDays)
                        result.append(formattedReminder)
                    }
                }
            }
            
            reminders = result.sorted(by: { $0.date > $1.date })
        })
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                if reminders.isEmpty {
                    Text("You have no reminders yet.")
                } else {
                    List {
                        ForEach(Array(reminders.enumerated()), id: \.offset) { index, reminder in
                            HStack {
                                ReminderLink(reminder: reminder)
                                    .swipeActions(edge: .leading) {
                                        Button {
                                            // Unsubscribe
                                            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [reminder.id])
                                            //Delete
                                            Firestore.firestore().collection("users/\(UserManager.shared.email)/reminders").document(reminder.id).delete()
                                            reminders.remove(at: index)
                                        } label: {
                                            Image("trash")
                                        }
                                        .tint(Color(.appRed))
                                    }
                                Spacer()
                                Button(action: { selectedReminder = reminder; showReminder.toggle() }, label: { Circle().frame(width: 1, height: 1).foregroundStyle(.clear) })
                            }
                                .listRowSeparator(index == 0 ? .hidden : .visible, edges: .top)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .padding()
            .onAppear { 
                subscribe()
                selectedReminder = nil
            }
            .navigationDestination(isPresented: $showReminder,
                                   destination: { UpdateReminder(reminder: selectedReminder)
            })
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color(.appEggWhite), for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    BackButton(title: "Reminders", dismissAction: dismiss)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showReminder.toggle()
                    }, label: {
                        Image(.plus)
                            .foregroundStyle(Color(.appOrange))
                    })
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct Reminder: Hashable {
    let id: String
    let date: Date
    let label: String
    let isEnabled: Bool
    let selectedDays: [String] // [DayOfWeek]
    
    static func == (lhs: Reminder, rhs: Reminder) -> Bool {
       return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }
}

struct ReminderLink: View {
    let reminder: Reminder
    @State var isEnabled: Bool

    init(reminder: Reminder) {
        self.reminder = reminder
        _isEnabled = State(initialValue: reminder.isEnabled)
    }
    
    var body: some View {
        VStack {
            Toggle(isOn: $isEnabled, label: {
                VStack(alignment: .leading) {
                    Text(reminder.date, style: .time)
                        .font(.title)
                    Text(reminder.label)
                        .font(.body)
                }
            })
            .tint(Color(.appOrange))
            .onChange(of: isEnabled) { newValue in
                if !newValue {
                    // Unsubscribe
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [reminder.id])
                } else {
                    // Re-subscribe
                    subscribeToReminder(reminderID: reminder.id, date: reminder.date, label: reminder.label, selectedDays: reminder.selectedDays)
                }
                Firestore.firestore().collection("users/\(UserManager.shared.email)/reminders").document(reminder.id)
                    .setData(["isEnabled": newValue], merge: true)
            }
        }
    }
}

#Preview {
    Reminders()
}


func subscribeToReminder(reminderID: String, date: Date, label: String, selectedDays: [String]) {
    // MARK: Set up local notifications
    let content = UNMutableNotificationContent()
    content.title = "The Bible Buddie"
    content.body = label
    
    // Configure the recurring date.
    let calendar = Calendar.current
    var dateComponents = DateComponents()
    dateComponents.calendar = calendar

    for index in 0..<calendar.weekdaySymbols.count {
        if selectedDays.contains(calendar.weekdaySymbols[index]) {
            dateComponents.weekday = index + 1  // ex. Tuesday
            dateComponents.hour = calendar.component(.hour, from: date)
            dateComponents.minute = calendar.component(.minute, from: date)
            
            // Create the trigger as a repeating event.
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            
            // Create the request
            let request = UNNotificationRequest(identifier: reminderID, content: content, trigger: trigger)

            // Schedule the request with the system.
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.add(request) { (error) in
               if error != nil {
                  // TODO: Log any errors.
               }
            }
        }
    }
}
