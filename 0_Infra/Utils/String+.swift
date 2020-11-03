//
//  String+.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/6/23.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//
import Foundation
import UIKit

extension String {
    var nsRange: NSRange {
        NSRange(location: 0, length: count)
    }
    
    func character(utf16CodeUnitIndex index: Int) -> Character {
        let codeUnitIndex = utf16.index(utf16.startIndex, offsetBy: index)
        let codeUnit = utf16[codeUnitIndex]

        if UTF16.isLeadSurrogate(codeUnit) {
            let nextCodeUnit = utf16[utf16.index(after: codeUnitIndex)]
            let codeUnits = [codeUnit, nextCodeUnit]
            let str = String(utf16CodeUnits: codeUnits, count: 2)
            return Character(str)
        } else if UTF16.isTrailSurrogate(codeUnit) {
            let previousCodeUnit = utf16[utf16.index(before: codeUnitIndex)]
            let codeUnits = [previousCodeUnit, codeUnit]
            let str = String(utf16CodeUnits: codeUnits, count: 2)
            return Character(str)
        } else {
            let unicodeScalar = UnicodeScalar(codeUnit)!
            return Character(unicodeScalar)
        }
    }
}
