//
//  SemWorldDataLayer2.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/10/17.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//
import RealmSwift

struct SemWorldDataLayer2 {
    let layer1: SemWorldDataLayer
}

extension SemWorldDataLayer2 {
    func unloadPerspective(_ conditionID: String, from placeID: String) {
        try! layer1.realm.write {
            layer1.removeCondition(conditionID, from: placeID)
            layer1.removePlace(placeID, fromConditionRank: conditionID)
        }
    }
    
    func loadPerspective(_ conditionID: String, on placeID: String) {
        try! layer1.realm.write {
            layer1.createConditionRank_IfNone(conditionID: conditionID)
            layer1.addCondition(conditionID, toPlace: placeID)
            layer1.addPlace(placeID, toConditionRank: conditionID)
        }
    }
}
