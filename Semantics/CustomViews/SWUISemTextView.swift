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
    
    let onCommit:() -> Void
    
    let onNotelinkTapped: (String) -> Void
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UITextView {
        let tmp = SemTextView(frame: .zero)
        
        tmp.text = $editedText.wrappedValue
        tmp.font = .preferredFont(forTextStyle: .title2)
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
        let parent: SWUISemTextView
        
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
            parent.onEditingChanged(true)
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            parent.onCommit()
        }
        
        func semTextViewNotelinkTapped(_ semTextView: SemTextView, link: String) {
            parent.onNotelinkTapped(link)
        }
    }
}
