//
//  NSRange+.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/6/2.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import Foundation

extension NSRange {
    init(lower: Int, includedUpper: Int) {
        self.init(location: lower, length: includedUpper - lower + 1)
    }
    
    func sidesCut(left: Int, right: Int) -> NSRange {
        NSRange(location: location + left, length: length - left - right)
    }
    
    func offset(by: Int) -> NSRange {
        NSRange(location: location + by, length: length)
    }
    
    func prefix(_ len: Int) -> NSRange {
        NSRange(location: location, length: len)
    }
    
    var includedUpper: Int {
        upperBound - 1
    }
}
