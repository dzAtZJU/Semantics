//
//  SyntaxHighlight.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/6/2.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//
import Foundation
import UIKit

struct SyntaxHighlight {
    
    static let noteLinkRegx = {
           try! NSRegularExpression(pattern: "(\\[\\[)(.+?[\\[\\]]*)\\]\\]", options: [])
    }()
    static func noteLinkInnerRange(in range: NSRange) -> NSRange {
        return range.inner(leftOffset: 2, rightOffset: 2)
    }
    static let noteLinkColor = UIColor.orange
    static let noteLinkInnerColor = UIColor.green
   
}
