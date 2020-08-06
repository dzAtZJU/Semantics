//
//  UIButton+.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/8/3.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import UIKit

extension UIButton {
    convenience init(systemName: String, scale: UIImage.SymbolScale) {
        self.init()
        translatesAutoresizingMaskIntoConstraints = false
        setImage(UIImage(systemName: systemName, withConfiguration: UIImage.SymbolConfiguration(pointSize: 40)), for: .normal)
    }
}
