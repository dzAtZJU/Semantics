//
//  IndexPath+.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/9/1.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import Foundation

extension IndexPath {
    func addSection(by: Int) -> IndexPath {
        IndexPath(row: row, section: section + by)
    }
}
