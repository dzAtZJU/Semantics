//
//  SemTextLayout.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/7/9.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import UIKit

class SemTextLayout: NSLayoutManager {
    override func drawGlyphs(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint) {
        super.drawGlyphs(forGlyphRange: glyphsToShow, at: origin)
        enumerateLineFragments(forGlyphRange: glyphsToShow) { (rect, _, _, range, _) -> Void in
            guard range.length >= 2 else {
                return
            }
            
            switch self.textStorage!.mutableString.substring(with: NSRange(location: range.location, length: 2)) {
            case "> ":
                Theme.Mark.verticalLine.set()
                UIBezierPath(rect: CGRect(origin: .init(x: rect.minX + 2.5, y: rect.minY), size: CGSize(width: 5, height: rect.height))).fill()
            case "* ":
                Theme.Mark.bullet.set()
                UIBezierPath(ovalIn: CGRect(origin: .init(x: rect.minX, y: rect.midY), size: CGSize(width: 10, height: 10))).fill()
            default:
                return
            }
        }
    }
}
