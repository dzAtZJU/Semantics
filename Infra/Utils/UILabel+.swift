//
//  UILabel+.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/8/13.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import UIKit

extension UILabel {
    func setHighlightedText(_ text: String, ranges: [NSValue]) {
        let attributes = [NSAttributedString.Key.font: font
            .withTraits(UIFontDescriptor.SymbolicTraits.traitBold
         )]
        let highlightedString = NSMutableAttributedString(string: text)
        
        // Each `NSValue` wraps an `NSRange` that can be used as a style attribute's range with `NSAttributedString`.
        let ranges = ranges.map { $0.rangeValue }
        ranges.forEach { (range) in
            highlightedString.addAttributes(attributes, range: range)
        }
        
        attributedText = highlightedString
    }
}
