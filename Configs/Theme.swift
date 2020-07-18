//
//  Theme.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/7/17.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import UIKit

struct Theme {
    private static let colors: [UIColor] = {
        [UIColor(named: "p0")!,
        UIColor(named: "p1")!,
        UIColor(named: "p2")!,
        UIColor(named: "p3")!]
    }()
    
    static func color(forProximity proximity: Int) -> [CGColor] {
        guard proximity < 3 else {
            return [colors[3].cgColor, colors[3].cgColor]
        }
        
        return [colors[proximity].cgColor, colors[proximity+1].cgColor]
    }
}
