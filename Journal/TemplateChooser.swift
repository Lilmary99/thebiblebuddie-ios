//
//  TemplateChooser.swift
//  tbb
//
//  Created by Mary Etefia on 11/14/23.
//  Copyright © 2023 Study Aloud. All rights reserved.
//

import SwiftUI

enum JournalTemplate: String, CaseIterable {
    case blank = "Blank"
    case sermons = "Sermons"
    case gratitude = "Gratitude"
    case lifeLessons = "Life Lessons"
    case scripture = "Scripture"
}

struct TemplateChooser: View {
    let templates = JournalTemplate.allCases
    
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                GeometryReader { geometry in
                    self.generateContent(in: geometry)
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color(.appEggWhite), for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    BackButton(title: "Journal", dismissAction: dismiss)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private func generateContent(in g: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(self.templates, id: \.self) { template in
                NavigationLink(destination: {
                    switch template {
                    case .blank: Blank()
                    case .sermons: Sermon()
                    case .gratitude: Numbered(type: .gratitude)
                    case .lifeLessons: Numbered(type: .lifeLessons)
                    case .scripture: Scripture()
                    }
                }, label: { self.item(for: template.rawValue) })
                    .padding([.horizontal, .vertical], 30.0)
                    .alignmentGuide(.leading, computeValue: { d in
                        if (abs(width - d.width) > g.size.width) {
                            width = 0
                            height -= d.height
                        }
                        let result = width
                        if template == self.templates.last! {
                            width = 0 // last item
                        } else {
                            width -= d.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: {d in
                        let result = height
                        if template == self.templates.last! {
                            height = 0 // last item
                        }
                        return result
                    })
            }
        }
    }

    func item(for template: String) -> some View {
        return VStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 4.0)
                .foregroundColor(Color(.appEggWhite))
                .frame(width: 125, height: 100)
            Text(template)
                .fontWeight(.semibold)
                .foregroundColor(Color(.appBlack))
        }
        .background(
            RoundedRectangle(cornerRadius: 10.0)
                .foregroundColor(Color(.appGray))
                .frame(width: 155, height: 168)
        )
    }
}

#Preview {
    TemplateChooser()
}
