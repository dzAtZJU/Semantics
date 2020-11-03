//
//  NSNotification+.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/8/4.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import Foundation
import CoreGraphics

extension Notification.Name {
    static let floatMoved = NSNotification.Name("floatMoved")
    static let floatAdding = NSNotification.Name("floatAdding")
}

extension Notification {
    struct FloatMoved {
        let center: CGPoint
    }
    
    struct FloatAdding {
        let word: Word
    }
}
