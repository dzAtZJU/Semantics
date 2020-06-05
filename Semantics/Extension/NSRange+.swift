//
//  NSRange+.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/6/2.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import Foundation

extension NSRange {
    func inner(leftOffset: Int, rightOffset: Int) -> NSRange {
        return NSRange(location: location + leftOffset, length: length - leftOffset - rightOffset)
    }
}
