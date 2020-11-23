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
    let _id: String
    init(_id: String) {
        self.title = _id
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

class DiscoverNextVM {
    let placeId: String
    
    let conditionVMs: [ConditionVM]
    
    var parent: MapVM?
    
    init(placeId placeId_: String, conditionIDs: [String]) {
        placeId = placeId_
        conditionVMs = conditionIDs.map {
            ConditionVM(_id: $0)
        }
    }
    
    func modifyNextOperator(atTitle title: String, value: Int) {
        let condition = conditionVMs.first {
            $0.title == title
            }!
        condition.setNextOperator(value: NextOperator(rawValue: value)!)
    }
    
    func runNextIteration(completion: @escaping (RealmSpace.SearchNextResult) -> Void) {
        let query = RealmSpace.SearchNextQuery(placeId: placeId, conditions: conditionVMs.filter({ $0.nextOperator != .noMatter }).map {
            RealmSpace.SearchNextQuery.ConditionInfo(conditionId: $0._id, nextOperator: $0.nextOperator
            )
        })

        RealmSpace.shared.searchNext(query: query) { result in
            let places = SemWorldDataLayer(realm: RealmSpace.shared.realm(RealmSpace.partitionValue)).queryPlaces(_ids: Array(result.places.map(\.placeId)))
            let annos = try! places.map { place throws -> SemAnnotation in
                SemAnnotation(place: place, type: .inDiscovering, color: .brown)
            }
            DispatchQueue.main.async {
                self.parent?.appendAnnotations(annos)
            }
            completion(result)
        }
    }
}
