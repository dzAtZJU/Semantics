//
//  CloudKitSpace.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/8/5.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import CloudKit

class CloukitSpace {
    private init() {}
    
    static let shared = CloukitSpace()
    
    let container = CKContainer(identifier: "iCloud.ind.paper.semantics.v3")
}

