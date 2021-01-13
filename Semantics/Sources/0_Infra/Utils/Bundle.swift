//
//  Bundle.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/8/5.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import Foundation

extension Bundle {
    static var appName: String {
        Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
    }
}
