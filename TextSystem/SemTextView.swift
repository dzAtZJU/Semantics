//
//  SemTextView.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/6/2.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

protocol SemTextViewDelegate: UITextViewDelegate {
    
    func semTextView(_ semTextView: SemTextView, didTapNotelink link: String)
    
    func semTextView(_ semTextView: SemTextView, didAddNotelinks added: Set<String>, didRemoveNotelinks removed: Set<String>)
}

class SemTextView: UITextView {
    
    var semDelegate: SemTextViewDelegate? {
        return delegate as? SemTextViewDelegate
    }
    
    override var delegate: UITextViewDelegate? {
        get {
            return super.delegate
        }
        set {
            precondition(newValue is SemTextViewDelegate?)
            super.delegate = newValue
        }
    }
    
    private lazy var tap = SemGestureRecognizer(target: self, action: #selector(Self.tapped))
    
    var semStorage: SemTextStorage {
        textStorage as! SemTextStorage
    }
    
    var inlineText: String {
        return semStorage.inlineText
    }
    
    init(frame: CGRect) {
        let container = NSTextContainer()
        
        let layoutManager = SemTextLayout()
        layoutManager.addTextContainer(container)
        
        let storage = SemTextStorage()
        storage.addLayoutManager(layoutManager)
        
        super.init(frame: frame, textContainer: container)
        
        layoutManager.delegate = self
        storage.delegate = self
        
        addGestureRecognizer(tap)
        
        inputAccessoryView  = {
            let bullet = UIBarButtonItem(image: UIImage(systemName: "list.bullet"), style: .plain, target: self, action: #selector(bulletTapped))
            let verticalLine = UIBarButtonItem(image: UIImage(systemName: "increase.quotelevel"), style: .plain, target: self, action: #selector(verticalLineTapped))
            let toolBar = UIToolbar(frame: .init(origin: .zero, size: .init(width: 300, height: 50)))
            toolBar.autoresizingMask = [.flexibleHeight]
            toolBar.items = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), bullet, verticalLine]
            return toolBar
        }()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SemTextView: NSLayoutManagerDelegate {
    func layoutManager(_ layoutManager: NSLayoutManager, shouldGenerateGlyphs glyphs: UnsafePointer<CGGlyph>, properties props: UnsafePointer<NSLayoutManager.GlyphProperty>, characterIndexes charIndexes: UnsafePointer<Int>, font aFont: UIFont, forGlyphRange glyphRange: NSRange) -> Int {
        print("Glyph \(glyphRange)")
        guard glyphRange.length >= 2 else {
            return 0
        }
        
        if case let firstCharacter = textStorage.mutableString.character(at: charIndexes[0]),
            firstCharacter == 0x3e || firstCharacter == 0x2a,
            textStorage.mutableString.character(at: charIndexes[1]) == 0x20 {
            var prop0 = props[0]
            prop0.insert(.null)
            var prop1 = props[1]
            prop1.insert(.null)
            [prop0, prop1].withUnsafeBufferPointer { pointer in
                layoutManager.setGlyphs(glyphs, properties: pointer.baseAddress!, characterIndexes: charIndexes, font: aFont, forGlyphRange: NSRange(location: glyphRange.location, length: 2))
            }
            return 2
        }
        
        return 0
    }
}

extension SemTextView: SemTextStorageDelegate {
    func textStorage(_ textStorage: NSTextStorage, didAddNotelinks addded: Set<String>, didRemoveNotelinks removed: Set<String>) {
        semDelegate?.textViewDidEndEditing?(self)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            self.semDelegate?.semTextView(self, didAddNotelinks: addded, didRemoveNotelinks: removed)
        }
    }
}

// MARK: Interaction
extension SemTextView {
    @objc func tapped(sender: SemGestureRecognizer) {
        if let touchedNotelinkCharIndex = sender.touchedNotelinkCharIndex, let link = semStorage.queryNoteLink(at: touchedNotelinkCharIndex) {
            semDelegate?.semTextView(self, didTapNotelink: link)
        }
    }
    
    @objc func bulletTapped() {
        let paragraph = semStorage.mutableString.paragraphRange(for: selectedRange)
        guard paragraph.length >= 2 else {
            textStorage.replaceCharacters(in: paragraph.prefix(0), with: "* ")
            return
        }
        
        let headRange = paragraph.prefix(2)
        switch semStorage.mutableString.substring(with: headRange) {
        case "* ":
            textStorage.replaceCharacters(in: headRange, with: "")
        case "> ":
            textStorage.replaceCharacters(in: headRange, with: "* ")
        default:
            textStorage.replaceCharacters(in: paragraph.prefix(0), with: "* ")
        }
    }
    
    @objc func verticalLineTapped() {
        let paragraph = semStorage.mutableString.paragraphRange(for: selectedRange)
        guard paragraph.length >= 2 else {
            textStorage.replaceCharacters(in: paragraph.prefix(0), with: "> ")
            return
        }
        
        let headRange = paragraph.prefix(2)
        switch semStorage.mutableString.substring(with: headRange) {
        case "> ":
            textStorage.replaceCharacters(in: headRange, with: "")
        case "* ":
            textStorage.replaceCharacters(in: headRange, with: "> ")
        default:
            textStorage.replaceCharacters(in: paragraph.prefix(0), with: "> ")
        }
    }
}
