//
//  Concurrency.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/6/9.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import Foundation

struct Concurrency {
    
    let serialQueue = DispatchQueue(label: "dedicated-queue")
    
    func avoidThreadExplosion(task: @escaping () -> Void) {
        serialQueue.async(execute: task)
    }
}
