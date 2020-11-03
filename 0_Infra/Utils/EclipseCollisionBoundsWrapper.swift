//
//  EclipseCollisionBoundsWrapper.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/5/25.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//
import UIKit

class EclipseCollisionBoundsWrapper: NSObject, UIDynamicItem {
    var center: CGPoint {
        get {
            return view.center
        }
        set {
            view.center = newValue
        }
    }
    
    var bounds: CGRect {
        return view.bounds
    }
    
    var transform: CGAffineTransform {
        get {
            return .identity
        }
        set {
        }
    }
    
    var collisionBoundsType: UIDynamicItemCollisionBoundsType {
        return .ellipse
    }

    let view: UIView
    
    init(_ view: UIView) {
        self.view = view
        super.init()
    }
}
