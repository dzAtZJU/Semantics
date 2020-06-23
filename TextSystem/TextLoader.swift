//
//  TextLoader.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/6/21.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//
import Foundation

extension String {
    func appending(neighborWords: Set<String>) -> Self {
        let nsString = self as NSString
        let inlineNeighborWords = Set(
            SyntaxHighlight.noteLinkRegx.matches(in: self, options: [], range: NSRange(location: 0, length: count)).map {
            nsString.substring(with: $0.range(at: 1))
        })
//        precondition(inlineNeighborWords.subtracting(neighborWords).isEmpty)
        
        return self + neighborWords.subtracting(inlineNeighborWords).map {
            "[[\($0)]]"
        }.joined()
    }
    
    func removingNeighborWords() -> Self {
        SyntaxHighlight.noteLinkRegx.stringByReplacingMatches(in: self, options: [], range: nsRange, withTemplate: "")
    }
}
