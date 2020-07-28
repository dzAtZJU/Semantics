//
//  SWUISemTextView.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/6/3.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import SwiftUI

struct SWUISemTextView: UIViewRepresentable {
    @Binding var editedText: String
    
    let onEditingChanged: (Bool) -> Void
    
    let onCommit:(String) -> Void
    
    let onNotelinkTapped: (String) -> Void
    
    let onNotelinksChanged: (Set<String>, Set<String>) -> Void
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UITextView {
        let tmp = SemTextView(frame: .zero)
        
        tmp.font = .preferredFont(forTextStyle: .title2)
        tmp.text = $editedText.wrappedValue
        tmp.backgroundColor = nil
        tmp.delegate = context.coordinator
        return tmp
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        if editedText != uiView.text {
            uiView.text = editedText
        }
    }
    
    class Coordinator: NSObject, SemTextViewDelegate {
        private let parent: SWUISemTextView
        
        private static let hintText = "new item"
        
        private var isFirstEditing = true
        
        init(_ parent: SWUISemTextView) {
            self.parent = parent
            super.init()
        }
        
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            guard text == "\n",
                case let paragraph = textView.textStorage.mutableString.paragraphRange(for: range),
                paragraph.length >= 2,
                case let head = textView.textStorage.mutableString.substring(with: NSRange(location: paragraph.location, length: 2)),
                head == "> " || head == "* " else {
                    return true
            }
            
            if paragraph.length == 2 {
                textView.textStorage.deleteCharacters(in: paragraph)
            } else {
                textView.insertText("\n")
                textView.insertText(head)
            }
            return false
        }
        
        func textViewDidChange(_ textView: UITextView) {
            parent.editedText = textView.text
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            if isFirstEditing && textView.text == Self.hintText {
                textView.text = ""
                isFirstEditing = false
            }
            
            parent.onEditingChanged(true)
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            parent.onCommit((textView as! SemTextView).inlineText)
        }
        
        func semTextView(_ semTextView: SemTextView, didTapNotelink link: String) {
            parent.onNotelinkTapped(link)
        }
        
        func semTextView(_ semTextView: SemTextView, didAddNotelinks added: Set<String>, didRemoveNotelinks removed: Set<String>) {
            parent.onNotelinksChanged(added, removed)
        }
    }
}
