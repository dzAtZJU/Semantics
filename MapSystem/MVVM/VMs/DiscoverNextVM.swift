//
//  DiscoverNextVM.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/8/13.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import Foundation
import Combine
import SwiftUI
import RealmSwift

enum NextOperator: Int {
    case better = 0
    case noWorse
    case noMatter
}

class ConditionVM {
    let title: String
    let _id: ObjectId
    init(title: String, _id: ObjectId) {
        self.title = title
        self._id = _id
    }
    
    @Published private(set) var nextOperator: NextOperator = .noMatter
    
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

protocol ConditionsVMDelegate {
    var selectedPlaceId: ObjectId? {
        get
    }
}

class DiscoverNextVM {
    var delegate: ConditionsVMDelegate?
    
    let conditionVMs: [ConditionVM]
    init(conditions: Results<Condition>) {
        conditionVMs = conditions.map {
            ConditionVM(title: $0.title, _id: $0._id)
        }
    }
    
    
    var iterationUpdater: ((SemWorldDataLayer.IterationQueryReslut) -> Void)! = nil
    
    func modifyNextOperator(atTitle title: String, value: Int) {
        let condition = conditionVMs.first {
            $0.title == title
            }!
        condition.setNextOperator(value: NextOperator(rawValue: value)!)
    }
    
    func runNextIteration() {
        guard let selectedPlaceId = delegate?.selectedPlaceId else {
            return
        }

        let conditions = conditionVMs.map {
            SemWorldDataLayer.IterationQuery.Condition(_id: $0._id, operator: $0.nextOperator)
        }
        let query = SemWorldDataLayer.IterationQuery(placeId: selectedPlaceId, conditions: conditions)

        conditionVMs.forEach {
            $0.resetNextOperator()
        }
        
        RealmSpace.shared.queue.async {
            SemWorldDataLayer(realm: RealmSpace.shared.newRealm(RealmSpace.partitionValue)).runNextIteration(query: query, completion: self.iterationUpdater)
        }
    }
}
