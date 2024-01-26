//
//  ViewSupport.swift
//  tbb
//
//  Created by Mary Etefia on 8/5/23.
//  Copyright © 2023 Study Aloud. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

let narrowHeight = 50.0
let broadHeight = 175.0

extension View {
    func tbbCapsuleStyle() -> some View {
        self
            .foregroundColor(.white)
            .accentColor(Color(.appOrange))
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .controlSize(.large)
    }
    
    func profileCapsuleStyle() -> some View {
        self
            .lineLimit(1)
            .padding(8.0)
            .background(RoundedRectangle(cornerRadius: 25.0).fill(Color(.appGray)))
    }
    
    func homescreenClipStyle() -> some View {
        self
            .frame(height: 201.0)
            .background(RoundedRectangle(cornerRadius: 16.0).shadow(radius: 2).foregroundStyle(Color(.appEggWhite)))
    }
    
    func sermonColumnStyle(height: Double) -> some View {
        self
            .padding()
            .frame(width: 150, height: height)
            .background(Rectangle().fill(Color(.appBlue)).frame(width: 150, height: height))
    }
    
    func numberedColumnStyle(height: Double) -> some View {
        self
            .padding()
            .frame(width: 70.0, height: height)
            .background(Rectangle().fill(Color(.appBlue)).frame(width: 70.0, height: height))
    }
    
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder func `if`<Content: View>(_ condition: @autoclosure () -> Bool, transform: (Self) -> Content) -> some View {
        if condition() {
            transform(self)
        } else {
            self
        }
    }
}

struct ResponseField: View {
    let hint: String
    let isPassword: Bool
    let response: Binding<String>
    
    init(hint: String, isPassword: Bool = false, response: Binding<String>) {
        self.hint = hint
        self.isPassword = isPassword
        self.response = response
    }
    
    var body: some View {
        HStack {
            if isPassword {
                SecureField(hint, text: response)
            } else {
                TextField(hint, text: response)
            }
        }
        .padding()
        .background(
            Capsule()
                .strokeBorder(Color(.appBlue), lineWidth: 0.8)
                .background(.white)
                .clipped()
        )
        .clipShape(Capsule())
    }
}

struct BackButton: View {
    let title: String
    let dismissAction: DismissAction
    
    var body: some View {
        HStack {
            Button {
                dismissAction()
            } label: {
                Image(.leftChevron)
            }
            Text(title)
                .font(.title)
                .foregroundColor(Color(.appBlack))
        }
    }
}

struct TBBLabel: View {
    let label: String
    let icon: String
    
    var body: some View {
        Label(title: {
            Text(label)
                .fontWeight(.semibold)
        }, icon: {
            Image(icon)
                .foregroundStyle(Color(.appOrange))
        })
    }
}

struct JournalRow: View {
    let type: JournalTemplate
    let height: Double
    let field: String
    let value: Binding<String>
    
    var body: some View {
        HStack(alignment: .center) {
            HStack {
                VStack(alignment: .leading) {
                    Text(field)
                        .fontWeight(.semibold)
                }
                .foregroundStyle(Color(.appBlack))
                Spacer()
            }
            .if(type == .sermons, transform: { view in
                view.sermonColumnStyle(height: height)
            })
            .if((type == .gratitude) || (type == .lifeLessons), transform: { view in
                view.numberedColumnStyle(height: height)
            })
            
            if height == narrowHeight {
                TextField("", text: value, axis: .horizontal)
                    .lineLimit(1)
            } else {
                CustomTextEditor(placeholder: "", text: value)
                    .frame(width: 175.0, height: height)
            }
        }
    }
}

struct CustomTextEditor: View {
    let placeholder: String
    let text: Binding<String>
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Text(placeholder)
            TextEditor(text: text)
                .opacity(text.wrappedValue == "" ? 0.7 : 1)
        }
    }
}

struct AddButton: View {
    var points: Binding<[String]>?
    var contexts: Binding<[String]>?

    var body: some View {
        Button.init(action: {
            if points != nil {
                points?.wrappedValue.append("")
            }
            if contexts != nil {
                contexts?.wrappedValue.append("")
            }
        }, label: {
            HStack {
                Image(.plus)
                    .foregroundStyle(Color(.appOrange))
                Text("Add Point")
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(.appBlack))
            }
        })
    }
}

struct BibleCircle: View {
    var body: some View {
        Circle()
            .frame(width: 8.0, height: 8.0)
            .foregroundColor(Color(.appOrange))
    }
}

struct DrawerPill: View {
    let title: String
    let selection: Binding<String>
    
    var body: some View {
        Text(title)
            .padding(8)
            .foregroundStyle(Color(.appBlack))
            .background(
                RoundedRectangle(cornerRadius: 25.0)
                    .foregroundStyle(Color(selection.wrappedValue == title ? .appBlue : .appGray))
                    .shadow(radius: 3)
            )
            .padding(5)
    }
}
