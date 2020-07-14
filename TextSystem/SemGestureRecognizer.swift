//
//  SemGestureRecognizer.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/7/9.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import UIKit

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
        

        let point = trackedTouch!.location(in: view)
        let touchedCharacterIndex = semTextView.layoutManager.characterIndex(for: point, in: semTextView.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        if semTextView.semStorage.queryNoteLink(at: touchedCharacterIndex) != nil {
            let rect = semTextView.layoutManager.boundingRect(forGlyphRange: NSRange(location: touchedCharacterIndex, length: 1), in: semTextView.textContainer)
            if rect.contains(point) {
                touchedNotelinkCharIndex = touchedCharacterIndex
                state = .possible
                return
            }
            
            
        }
        
        state = .failed
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

