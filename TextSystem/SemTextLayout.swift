//
//  SemTextLayout.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/7/9.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import UIKit

class SemTextLayout: NSLayoutManager {
    override init() {
        super.init()
        allowsNonContiguousLayout = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawGlyphs(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint) {
        super.drawGlyphs(forGlyphRange: glyphsToShow, at: origin)
        
        enumerateLineFragments(forGlyphRange: glyphsToShow) { (rect, _, _, range, _) -> Void in
            let paragraph = self.textStorage!.mutableString.paragraphRange(for: range)
            guard paragraph.length >= 2 else {
                return
            }
            
            guard range.location - paragraph.location <= 2 else {
                return
            }
            
            let head = self.textStorage!.mutableString.substring(with: paragraph.prefix(2))
            switch head {
            case "> ":
                UIColor.quaternaryLabel.set()
                UIBezierPath(rect: CGRect(origin: .init(x: rect.minX + 2.5, y: rect.minY), size: CGSize(width: 5, height: rect.height))).fill()
            case "* ":
                UIColor.quaternaryLabel.set()
                UIBezierPath(ovalIn: CGRect(origin: .init(x: rect.minX, y: rect.midY), size: CGSize(width: 10, height: 10))).fill()
            default:
                return
            }
        }
    }
}
