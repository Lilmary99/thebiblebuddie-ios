//
//  Settings.swift
//  tbb
//
//  Created by Mary Etefia on 10/15/23.
//  Copyright © 2023 Study Aloud. All rights reserved.
//

import SwiftUI

enum SettingsView: Int {
    case settings = 0
    case changeLogin
    case reminders
    case about
    case languages
}

struct SettingsLink: View {
    let title: String
    let link: SettingsView
    let settingsView: Binding<SettingsView>
    
    var body: some View {
        HStack {
            Button(action: { settingsView.wrappedValue = link }, label: {
                Text(title)
            })
            Spacer()
            Image(.chevron)
        }
    }
}

struct Settings: View {
    let userManager = UserManager.shared
    
    @EnvironmentObject private var appRootManager: AppRootManager
    @Environment(\.dismiss) private var dismiss
    @State var pushNotifications = true
    @State var doNotDisturb = false
    @State var presentLogoutAlert = false
    
    @State private var leaveSettingsPage: Bool
    @State private var settingsView: SettingsView = .settings
    
    init() {
        _leaveSettingsPage = State(initialValue: false)
    }
    
    // Note: Use of `Group` is just to satisfy SwiftUI compiler. It means nothing for the sctual structure of the views.
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                List {
                    // TODO: Replace Goals() with actual view
                    Group {
                        Text("Account")
                            .fontWeight(.semibold)
                            .listRowSeparator(.hidden, edges: .top)
                        
                        SettingsLink(title: "Change login credentials", link: .changeLogin, settingsView: $settingsView)
                        
                        Toggle("Push Notifications", isOn: $pushNotifications)
                            .tint(Color(.appOrange))
                        
                        SettingsLink(title: "Set a customized reminder", link: .reminders, settingsView: $settingsView)
                            .listRowSeparator(.hidden, edges: .bottom)
                    }

                    Group {
                        Spacer()
                            .listRowSeparator(.hidden, edges: .bottom)

                        Text("Reading Mode")
                            .fontWeight(.semibold)
                    }
                    
                    Group {
                        Spacer()
                            .listRowSeparator(.hidden, edges: .bottom)

                        Text("General")
                            .fontWeight(.semibold)
                        SettingsLink(title: "About", link: .about, settingsView: $settingsView)
                        SettingsLink(title: "Languages", link: .languages, settingsView: $settingsView)

                        
                        // TODO: Replace 1maryetefia @ gmail.com
                        Button(action: {
                            Email.shared.sendEmail(subject: "Support Request", body: "", to: "1maryetefia@gmail.com")
                        }) {
                            Text("Help")
                        }
                        
                        Button(action: {
                            do {
                                try userManager.logout()
                                appRootManager.currentRoot = .authentication
                            } catch(let error) {
                                logger.error("Could not log user out: \(error.localizedDescription)")
                            }
                        }) {
                            Text("Logout")
                        }
                        // TODO: Perform action upon primaryButton click
                        .alert(isPresented: $presentLogoutAlert) {
                            Alert(title: Text("Are you sure?"),
                                  primaryButton: .default(Text("Logout")),
                                  secondaryButton: .cancel(Text("Cancel").foregroundColor(Color(.appOrange)))
                            )
                        }
                        .listRowSeparator(.hidden, edges: .bottom)
                    }
                }
                .listStyle(.inset)
            }
            .onAppear {
                settingsView = .settings
            }
            .onChange(of: settingsView) { newValue in
                if newValue != .settings {
                    leaveSettingsPage = true
                }
            }
            .onChange(of: pushNotifications) { newValue in
                if !newValue {
                    userManager.unsubscribeFromNotifications()
                } else {
                    Task { await userManager.subscribeToReminders() }
                }
            }
            .navigationDestination(isPresented: $leaveSettingsPage) {
                switch settingsView {
                case .changeLogin:
                    ChangeLogin()
                case .reminders:
                    Reminders()
                case .about:
                    About()
                case .languages:
                    Languages()
                default:
                    EmptyView()
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color(.appEggWhite), for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    BackButton(title: "Settings", dismissAction: dismiss)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    Settings()
}
