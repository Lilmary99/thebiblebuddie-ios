//
//  About.swift
//  tbb
//
//  Created by Mary Etefia on 10/15/23.
//  Copyright © 2023 Study Aloud. All rights reserved.
//

import SwiftUI

struct About: View {
    @Environment(\.openURL) var openURL
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Bible Buddie")
                    Text("Lorem ipsum")
                    Text("Our Beliefs")
                    Text("Lorem ipsum")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color(.appEggWhite), for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    BackButton(title: "About", dismissAction: dismiss)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        openURL(URL(string: "https://biblebuddie.com/")!)
                    }, label: {
                        Image("safari")
                    })
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    About()
}
