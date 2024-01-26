//
//  NumberedButtons.swift
//  tbb
//
//  Created by Mary Etefia on 11/22/23.
//  Copyright © 2023 Study Aloud. All rights reserved.
//

import SwiftUI

struct NumberedButtons: View {
    let filter: Binding<BibleFilter>
    let forChapters: Bool
    let verseReference: Binding<VerseReference>
    let verseReferenceCaptured: Binding<VerseReference>
    
    let provider: BibleProvider
    
    @State private var numerics: [String] = []
    
    init(filter: Binding<BibleFilter>, forChapters: Bool, verseReference: Binding<VerseReference>, verseReferenceCaptured: Binding<VerseReference>) {
        self.filter = filter
        self.forChapters = forChapters
        self.verseReference = verseReference
        self.verseReferenceCaptured = verseReferenceCaptured
        
        self.provider = BibleProvider(book: verseReferenceCaptured.book.wrappedValue, chapter: forChapters ? nil : String(verseReferenceCaptured.chapter.wrappedValue))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20.0) {
            HStack {
                Text(forChapters ? "Select a chapter." : "Select a verse.")
                
                Spacer()
                
                Button(action: {
                    // Reset VerseReference
                    if forChapters {
                        verseReferenceCaptured.book.wrappedValue = verseReference.book.wrappedValue
                    } else {
                        verseReferenceCaptured.chapter.wrappedValue = verseReference.chapter.wrappedValue
                    }
                    filter.wrappedValue = forChapters ? .books : .chapters
                }, label: {
                    Text("Back")
                })
            }
            .foregroundStyle(Color(.appDarkGray))
            
            Divider()
            
            HStack(alignment: .firstTextBaseline) {
                BibleCircle()
                Text("\(verseReferenceCaptured.book.wrappedValue) \(forChapters ? "" : String(verseReferenceCaptured.chapter.wrappedValue))")
                    .foregroundStyle(Color(.appBlack))
            }
            
            GeometryReader { geometry in
                ScrollView(.vertical, showsIndicators: true) {
                    
                    self.generateContent(in: geometry)
                }
            }
        }
        .padding()
        .onReceive(self.provider.$numerics, perform: { newNumerics in
            numerics = newNumerics
        })
    }
    
    private func generateContent(in g: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        
        return ZStack(alignment: .topLeading) {
            ForEach(self.numerics, id: \.self) { number in
                Button(action: {
                    if forChapters {
                        verseReferenceCaptured.chapter.wrappedValue = Int(number)!
                        filter.wrappedValue = .verses
                    } else {
                        verseReferenceCaptured.verse.wrappedValue = Int(number)!
                        filter.wrappedValue = .bible
                    }
                }, label: {
                    ZStack(alignment: .center) {
                        Circle()
                            .foregroundStyle(Color(.appGray))
                        
                        Text(number)
                            .foregroundStyle(Color(.appBlack))
                            .padding(8.0)
                    }
                })
                .frame(width: 45, height: 45)
                .padding([.horizontal, .vertical], 4)
                .alignmentGuide(.leading, computeValue: { d in
                    if (abs(width - d.width) > g.size.width) {
                        width = 0
                        height -= d.height
                    }
                    let result = width
                    if number == self.numerics.last! {
                        width = 0 // last item
                    } else {
                        width -= d.width
                    }
                    return result
                })
                .alignmentGuide(.top, computeValue: {d in
                    let result = height
                    if number == self.numerics.last! {
                        height = 0 // last item
                    }
                    return result
                })
            }
        }
    }
}
