//
//  NSRange+.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/6/2.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import Foundation

extension NSRange {
    func sidesCut(left: Int, right: Int) -> NSRange {
        NSRange(location: location + left, length: length - left - right)
    }
    
    func offset(by: Int) -> NSRange {
        NSRange(location: location + by, length: length)
    }
    
    func prefix(_ len: Int) -> NSRange {
        NSRange(location: location, length: len)
    }
}
