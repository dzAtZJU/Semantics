//
//  SemStyle.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/6/2.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//
import Foundation
import UIKit

struct SemTextProcessor {
    static func oneCharTagInnerRange(in range: NSRange) -> NSRange {
        return range.sidesCut(left: 1, right: 1)
    }
    
    static func twoCharsTagInnerRange(in range: NSRange) -> NSRange {
        return range.sidesCut(left: 2, right: 2)
    }
}

struct SyntaxHighlight {
    private static let noteLinkRegxStr = "\\[\\[[^\\[\\]]+\\]\\]"
    private static let noteLinkAtEndRegxStr = noteLinkRegxStr + "$"
    static let noteLinkRegx = {
           try! NSRegularExpression(pattern: noteLinkRegxStr, options: [])
    }()
    static let noteLinkRegxAtEnd = {
        try! NSRegularExpression(pattern: noteLinkAtEndRegxStr, options: [])
    }()
}

extension String {
    func iconMarkuped() -> String {
        ":\(self):"
    }
}

struct SemanticReplacer {
    static let iconRegx = {
        try! NSRegularExpression(pattern: ":.+?:", options: [])
    }()
}

struct SemStyle {
    static let verticalLineOrBulletRegx = {
        try! NSRegularExpression(pattern: "^(\\* )|(\\> )", options: [])
    }()
}
