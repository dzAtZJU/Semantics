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

        let layoutManager = NSLayoutManager()
        layoutManager.addTextContainer(container)

        let storage = SemTextStorage()
        storage.addLayoutManager(layoutManager)
        
        super.init(frame: frame, textContainer: container)
        
        storage.delegate = self
        
        addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func tapped(sender: SemGestureRecognizer) {
        if let touchedNotelinkCharIndex = sender.touchedNotelinkCharIndex, let link = semStorage.queryNoteLink(at: touchedNotelinkCharIndex) {
            semDelegate?.semTextView(self, didTapNotelink: link)
        }
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

class SemGestureRecognizer: UIGestureRecognizer {
    private var trackedTouch : UITouch?
    private(set) var touchedNotelinkCharIndex: Int?
    
    private var semTextView: SemTextView {
        view as! SemTextView
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        
        guard touches.count == 1 else {
            state = .failed
            return
        }
        
        if trackedTouch == nil {
            trackedTouch = touches.first
        } else {
            touches.forEach {
                if $0 != trackedTouch {
                    ignore($0, for: event)
                }
            }
        }
        
        let touchedCharacterIndex = semTextView.layoutManager.characterIndex(for: trackedTouch!.location(in: view), in: semTextView.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        let touchedGlyphIndex = semTextView.layoutManager.glyphIndex(for: trackedTouch!.location(in: view), in: semTextView.textContainer)
        
        let rect = semTextView.layoutManager.boundingRect(forGlyphRange: NSRange(location: touchedGlyphIndex, length: 1), in: semTextView.textContainer)
        
        if semTextView.semStorage.queryNoteLink(at: touchedCharacterIndex) != nil {
            touchedNotelinkCharIndex = touchedCharacterIndex
            state = .possible
        } else {
            state = .failed
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        
        let newTouch = touches.first
        guard newTouch == self.trackedTouch, touches.count == 1 else {
           self.state = .failed
           return
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        
        guard state == .possible else {
            state = .failed
            return
        }
        
        let newTouch = touches.first
        guard newTouch == self.trackedTouch, touches.count == 1 else {
           self.state = .failed
           return
        }
        
        let touchedCharacterIndex = semTextView.layoutManager.characterIndex(for: trackedTouch!.location(in: view), in: semTextView.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        if touchedCharacterIndex == touchedNotelinkCharIndex {
            state = .recognized
        } else {
            state = .failed
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesCancelled(touches, with: event)
        
        trackedTouch = nil
        touchedNotelinkCharIndex = nil
        state = .cancelled
    }
    
    override func reset() {
        super.reset()
        
        trackedTouch = nil
        touchedNotelinkCharIndex = nil
    }
}
