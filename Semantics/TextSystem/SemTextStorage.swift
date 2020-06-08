//
//  SemTextStorage.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/6/2.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import UIKit

class SemTextStorage: NSTextStorage {
    private var defaultForegroundColor = UIColor.white
    
    private let storage = NSMutableAttributedString()
    
    override var string: String {
        return storage.string
    }
    
    override func attributes(at location: Int, effectiveRange range: NSRangePointer?) -> [NSAttributedString.Key : Any] {
        return storage.attributes(at: location, effectiveRange: range)
    }
    
    override func replaceCharacters(in range: NSRange, with str: String) {
        storage.replaceCharacters(in: range, with: str)
        edited(.editedCharacters, range: range, changeInLength: str.count - range.length)
    }
    
    override func setAttributes(_ attrs: [NSAttributedString.Key : Any]?, range: NSRange) {
        storage.setAttributes(attrs, range: range)
        edited(.editedAttributes, range: range, changeInLength: 0)
    }
    
    override func edited(_ editedMask: NSTextStorage.EditActions, range editedRange: NSRange, changeInLength delta: Int) {
        print("\(type(of: self)).\(#function)" + ": \(editedMask) \(editedRange) \(delta)")
        super.edited(editedMask, range: editedRange, changeInLength: delta)
    }
    
    override func processEditing() {
        print("\(type(of: self)).\(#function)")
        semProcessEditing()
        super.processEditing()
    }
    
    func semProcessEditing() {
        let paragraphRange = mutableString.paragraphRange(for: editedRange)
        addAttribute(.foregroundColor, value: defaultForegroundColor, range: paragraphRange)
        SyntaxHighlight.noteLinkRegx.enumerateMatches(in: string, options: [], range: paragraphRange) { (result, flags, stop) -> Void in
            let range = result!.range
            
            addAttribute(.foregroundColor, value: SyntaxHighlight.noteLinkColor, range: range)
            let innerRange = SyntaxHighlight.noteLinkInnerRange(in: range)
            addAttribute(.foregroundColor, value: SyntaxHighlight.noteLinkInnerColor, range: innerRange)
            
            let notetitle = storage.mutableString.substring(with: innerRange)
            addAttribute(.notelink, value: notetitle, range: range)
        }
    }
}

extension SemTextStorage {
    func queryNoteLink(at location: Int) -> String? {
        if length > location, let link = attribute(.notelink, at: location, effectiveRange: nil) as? String {
            return link
        }

        return nil
    }
}
