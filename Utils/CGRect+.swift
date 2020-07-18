//
//  CGRect+.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/7/17.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import CoreGraphics

extension CGRect {
    var bottomRight: CGPoint {
        .init(x: maxX, y: maxY)
    }
}
