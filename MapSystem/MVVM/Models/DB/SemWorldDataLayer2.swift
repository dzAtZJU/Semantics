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
    func projectCondition(_ conditionID: String, on placeID: String) {
        try! layer1.realm.write {
            layer1.createConditionRank_IfNone(conditionID: conditionID)
            layer1.addCondition(conditionID, toPlace: placeID)
            layer1.addPlace(placeID, toConditionRank: conditionID)
        }
    }
    
    func withdrawCondition(_ conditionID: String, from placeID: String) {
        try! layer1.realm.write {
            layer1.removeCondition(conditionID, fromPlace: placeID)
            layer1.removePlace(placeID, fromConditionRank: conditionID)
        }
    }
    
    func queryConditionRank_List(havingPlace placeID: String) -> [ConditionRank] {
        guard let placeStory = layer1.queryPlaceStory(placeID: placeID) else {
            fatalError()
        }
        
        let placeperspectives = placeStory.conditionID_List
        return try! layer1.loadConditionRank_List().filter { (conditionRank: ConditionRank) throws -> Bool in
            placeperspectives.contains(conditionRank.conditionID)
        }
    }
    
    func projectPerspective(_ perspectiveID: String, on placeID: String) {
        try! layer1.realm.write {
            layer1.addPerspective(perspectiveID, toPlace: placeID)
        }
    }
    
    func withdrawPerspective(_ perspectiveID: String, from placeID: String) {
        try! layer1.realm.write {
            layer1.removePerspective(perspectiveID, fromPlace: placeID)
        }
    }
}