//
//  OneFingerTableView.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/7/20.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import UIKit

class OneFingerTableView: UITableView {
    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == panGestureRecognizer {
            return panGestureRecognizer.numberOfTouches == 1
        }
        
        return true
    }
}
