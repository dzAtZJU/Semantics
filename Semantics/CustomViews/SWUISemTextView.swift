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
        tmp.returnKeyType = .done
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
        }
        
        func textViewDidChange(_ textView: UITextView) {
            parent.editedText = textView.text
        }
        
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            if text == "\n" {
                textView.resignFirstResponder()
                return true
            }
            
            return true
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
