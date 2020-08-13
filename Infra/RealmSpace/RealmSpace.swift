//
//  RealmSpace.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/8/12.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import RealmSwift

class RealmSpace {
    private init() {}
       
    static let shared = RealmSpace()
       
    let app = RealmApp(id: "semantics-tonbj")
}

