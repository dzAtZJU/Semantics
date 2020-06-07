//
//  TextOnCircle.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/5/21.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import SwiftUI

protocol TextOnCircleDelegate {
    func onCommit(oldText: String, newText: String)
}

struct TextOnCircle: View {
    static let bgColor = Color.red
    
    let text: String
    
    var delegate: TextOnCircleDelegate?
    
    @State var editedText: String
    
    @State var beforeAnyEdit = true
    
    @State var isActive = false
    
    @State var notelink = ""
    
    init(_ text: String) {
        self.text = text
        _editedText = State(initialValue: text)
    }
    
    var body: some View {
        VStack {
            NavigationLink(destination: SemSetView(title: notelink), isActive: $isActive) {
                Text("")
            }
            SWUISemTextView(editedText: $editedText,
                            onEditingChanged: { _ in },
                            onCommit: { self.delegate?.onCommit(oldText: self.text, newText: self.editedText) },
                            onNotelinkTapped: { notelink in
                                self.isActive = true
                                self.notelink = notelink
            })
                .padding()
                .background(GeometryReader { geomegtry in
                    Circle()
                        .fill(Self.bgColor)
                        .aspectRatio(1, contentMode: .fill)
                        .frame(width: geomegtry.size.width)
                    
                })
        }
        .keyboardAdaptive()
    }
}



struct TextOnCircle_Previews: PreviewProvider {
    static var previews: some View {
        TextOnCircle("大招操作失误")
    }
}
