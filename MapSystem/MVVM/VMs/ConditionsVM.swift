//
//  ConditionsVM.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/8/13.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import Foundation
import Combine

class ConditionVM {
    enum NextOperator: Int {
        case better = 0
        case noWorse
        case noMatter
    }
    
    enum `Type` {
        case bool
    }
    let subTitle = ""
    let caterogy = ""
    let type = Type.bool
    
    @Published private(set) var nextOperator: NextOperator = .noMatter
    
    let title: String
    init(title: String) {
        self.title = title
    }
    
    func setNextOperator(value: NextOperator) {
        if nextOperator != value {
            nextOperator = value
        }
    }
    
    func resetNextOperator() {
        if nextOperator != .noMatter {
            nextOperator = .noWorse
        }
    }
}

class ConditionsVM {
    let conditions = [ConditionVM(title: "卫生间"), ConditionVM(title: "咖啡"), ConditionVM(title: "空间感"), ConditionVM(title: "小孩吵"), ConditionVM(title: "背景音乐"), ConditionVM(title: "网络")]
    
    func modifyNextOperator(atTitle title: String, value: Int) {
        let condition = conditions.first {
            $0.title == title
            }!
        condition.setNextOperator(value: ConditionVM.NextOperator(rawValue: value)!)
    }
    
    func runNextIteration() {
        let filters = conditions.map {
            "\($0.title): \($0.nextOperator.rawValue)"
        }.joined(separator: ",")
        print("runNextIteration: \(filters)")
        conditions.forEach {
            $0.resetNextOperator()
        }
    }
}
