//
//  SemSetSubwordVC.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/6/8.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import SwiftUI
import UIKit

protocol SemSetSubwordVCDelegate: class {
    func upadteSubword(oldText: String, newText: String)
    func didChangeFirstResponderState(semSetSubwordVC: SemSetSubwordVC, to: Bool)
}

class SemSetSubwordVC: UIViewController {
    private static let hintText = "new item"
    
    private let firstText: String
    private var isFirstEditing = true
    
    private var oldText: String
    
    let delegate: SemSetSubwordVCDelegate
    
    var dynamicItem: UIDynamicItem? = nil
    
    lazy var textView: SemTextView = {
        let r = SemTextView(frame: .zero)
        r.translatesAutoresizingMaskIntoConstraints = false
        r.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        r.text = firstText
        r.delegate = self
        return r
    }()
    
    var subwordName: String {
        textView.text
    }
    
    init(text: String, delegate delegate_: SemSetSubwordVCDelegate) {
        delegate = delegate_
        firstText = text
        oldText = firstText
        
        super.init(nibName: nil, bundle: nil)
    }
    
    override func loadView() {
        view = UIView()
        view.addSubview(textView)
    }
    
    override func viewSafeAreaInsetsDidChange() {
        textView.frame = view.bounds.inset(by: view.safeAreaInsets)
    }
    
    
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        view.backgroundColor = nil
    }
}

extension SemSetSubwordVC: SemTextViewDelegate {
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
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        delegate.didChangeFirstResponderState(semSetSubwordVC: self, to: true)
        if isFirstEditing && textView.text == Self.hintText {
            textView.text = ""
            isFirstEditing = false
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        delegate.didChangeFirstResponderState(semSetSubwordVC: self, to: false)
        let newText = (textView as! SemTextView).inlineText
        delegate.upadteSubword(oldText: oldText, newText: newText)
        oldText = newText
    }
}
