//
//  UIButton+.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/8/3.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import UIKit

extension UIButton {
    convenience init(systemName: String, textStyle: UIFont.TextStyle = .title1, target: Any? = nil, selector: Selector? = nil) {
        self.init()
        translatesAutoresizingMaskIntoConstraints = false
        setImage(UIImage(systemName: systemName, withConfiguration: UIImage.SymbolConfiguration(textStyle: textStyle)), for: .normal)
        if let selector = selector {
            addTarget(target, action: selector, for: .touchUpInside)
        }
    }
}
