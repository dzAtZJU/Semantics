//
//  SemTextStorage.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/6/2.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import UIKit
import Iconic

protocol SemTextStorageDelegate: NSTextStorageDelegate {
    func textStorage(_ textStorage: NSTextStorage, didAddNotelinks added: Set<String>, didRemoveNotelinks removed: Set<String>)
}

class SemTextStorage: NSTextStorage {
    private var defaultForegroundColor = UIColor.white
    
    var semDelegate: SemTextStorageDelegate? {
        return delegate as? SemTextStorageDelegate
    }
    
    override var delegate: NSTextStorageDelegate? {
        get {
            return super.delegate
        }
        set {
            precondition(newValue is SemTextStorageDelegate?)
            super.delegate = newValue
        }
    }
    
    private let storage = NSMutableAttributedString()
    
    // MARK: Manage Storage
    
    override var string: String {
        return storage.string
    }
    
    override func attributes(at location: Int, effectiveRange range: NSRangePointer?) -> [NSAttributedString.Key : Any] {
        return storage.attributes(at: location, effectiveRange: range)
    }
    
    override func replaceCharacters(in range: NSRange, with str: String) {
        // MARK: Notelink
        if str.isEmpty {
            let paragraphRange = mutableString.paragraphRange(for: range)
            let result = SyntaxHighlight.noteLinkRegxAtEnd.rangeOfFirstMatch(in: string, options: [], range: paragraphRange)
            if result.location != NSNotFound, range.length < result.length {
                let innerRange = SemTextProcessor.twoCharsTagInnerRange(in: result)
                let notetitle = storage.mutableString.substring(with: innerRange)
                
                storage.replaceCharacters(in: result, with: "")
                edited(.editedCharacters, range: result, changeInLength: str.count - result.length)
               
                semDelegate?.textStorage(self, didAddNotelinks: [], didRemoveNotelinks: [notetitle])
                return
            }
        }
        
        storage.replaceCharacters(in: range, with: str)
        edited(.editedCharacters, range: range, changeInLength: str.count - range.length)
    }
    
    override func setAttributes(_ attrs: [NSAttributedString.Key : Any]?, range: NSRange) {
        storage.setAttributes(attrs, range: range)
        edited(.editedAttributes, range: range, changeInLength: 0)
    }
    
    // MARK: Post-Process
    
    override func processEditing() {
        //        print("\(type(of: self)).\(#function)")
        semProcessEditing()
        super.processEditing()
    }
    
    func semProcessEditing() {
        let paragraphRange = mutableString.paragraphRange(for: editedRange)
        addAttribute(.foregroundColor, value: defaultForegroundColor, range: paragraphRange)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.headIndent = 10
        paragraphStyle.firstLineHeadIndent = 10
        addAttribute(.paragraphStyle, value: paragraphStyle, range: paragraphRange)
        
        // MARK: VerticalLine, Bullet
//        if let _ = SemStyle.verticalLineOrBulletRegx.firstMatch(in: mutableString.substring(with: paragraphRange), options: [], range: NSRange(location: 0, length: paragraphRange.length)) {
//            paragraphStyle.headIndent = 0
//            paragraphStyle.firstLineHeadIndent = 0
//            addAttributes([.paragraphStyle: paragraphStyle], range: paragraphRange)
//        }

        // MARK: Notelink
        var exsistingNotelinks: Set<String> = []
        enumerateAttribute(.notelink, in: paragraphRange, options: []) { value, range , _ in
            guard let value = value else {
                return
            }
            removeAttribute(.notelink, range: range)
            exsistingNotelinks.insert(value as! String)
        }
        
        var matchedNotelinks: Set<String> = []
        SyntaxHighlight.noteLinkRegx.enumerateMatches(in: string, options: [], range: paragraphRange) { (result, flags, stop) -> Void in
            let range = result!.range
            addAttribute(.foregroundColor, value: SyntaxHighlight.noteLinkColor, range: range)
            
            let innerRange = SemTextProcessor.twoCharsTagInnerRange(in: range)
            addAttribute(.foregroundColor, value: SyntaxHighlight.noteLinkInnerColor, range: innerRange)
            
            let notetitle = storage.mutableString.substring(with: innerRange)
            addAttribute(.notelink, value: notetitle, range: range)
            matchedNotelinks.insert(notetitle)
        }
        
        let newNotelinks = matchedNotelinks.subtracting(exsistingNotelinks)
        if !newNotelinks.isEmpty {
            semDelegate?.textStorage(self, didAddNotelinks: newNotelinks, didRemoveNotelinks: [])
        }
        
        // MARK: Icon
        var offset = 0
        SemanticReplacer.iconRegx.enumerateMatches(in: string, options: [], range: paragraphRange) { (result, flags, stop) -> Void in
            let matchedRange = result!.range.offset(by: offset)
            let innerRange = SemTextProcessor.oneCharTagInnerRange(in: matchedRange)
            let iconName = storage.mutableString.substring(with: innerRange)
            let fontSize = ((attribute(.font, at: matchedRange.location, effectiveRange: nil) as! UIFont).fontDescriptor.fontAttributes[.size] as! NSNumber).floatValue
            let iconAttriburedString = FontAwesomeIcon(named: iconName).attributedString(ofSize: CGFloat(fontSize), color: defaultForegroundColor)
            replaceCharacters(in: matchedRange, with: iconAttriburedString)
            addAttribute(.iconName, value: iconName, range: NSRange(location: matchedRange.location, length: iconAttriburedString.length))
            
            offset += iconAttriburedString.length - matchedRange.length
        }
    }
}

extension SemTextStorage {
    var inlineText: String {
        get {
            let storedText = storage.mutableString.mutableCopy() as! NSMutableString
            var offset = 0
            
            enumerateAttribute(.iconName, in: NSRange(location: 0, length: length)) {(value, matchedRange, _) in
                guard let iconName = value as? String else {
                    return
                }
                
                let iconMarkup = iconName.iconMarkuped()
                storedText.replaceCharacters(in: matchedRange.offset(by: offset), with: iconMarkup)
                
                offset += iconMarkup.count - matchedRange.length
            }
            return (storedText.copy() as! NSString) as String
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
