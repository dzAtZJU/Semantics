//
//  Model.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/5/18.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//
import UIKit

struct Resource {
    let imageName: String
}

struct Behavior {
    let description: String
    
    let resource: Resource
}

struct Feelings {
    let name: String
    
    let behavior: Behavior
}
