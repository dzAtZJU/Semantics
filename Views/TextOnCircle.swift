//
//  TextOnCircle.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/5/21.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import SwiftUI

struct TextOnCircle: View {
    @State private(set) var initialText: String
    
    let onCommit: (String, String) -> Void
    
    @State var editedText: String
    
    @State var isActive = false
    
    @State var notelink = ""
    
    init(_ text: String, onCommit onCommit_: @escaping (_ oldText: String, _ newText: String) -> Void) {
        _initialText = State(initialValue: text)
        onCommit = onCommit_
        _editedText = State(initialValue: text)
    }
    
    var body: some View {
        VStack {
            NavigationLink(destination: SemSetView(title: notelink), isActive: $isActive) {
                Text("")
            }
            SWUISemTextView(editedText: $editedText,
                            onEditingChanged: { _ in },
                            onCommit: { inlineText in
                                self.onCommit(self.initialText, inlineText)
                                self.initialText = inlineText
            },
                            onNotelinkTapped: { notelink in
                                self.isActive = true
                                self.notelink = notelink
            },
                            onNotelinksChanged: { (added, removed) in
                                
            })
                .padding()
                .background(GeometryReader { geomegtry in
                    Circle()
                        .fill(Color(UIColor.quaternarySystemFill))
                        .aspectRatio(1, contentMode: .fill)
                        .frame(width: geomegtry.size.width)
                    
                })
        }
        .keyboardAdaptive()
    }
}



//struct TextOnCircle_Previews: PreviewProvider {
//    static var previews: some View {
//        TextOnCircle("大招操作失误", onCommit: {_,_ in
//
//        }, )
//    }
//}
