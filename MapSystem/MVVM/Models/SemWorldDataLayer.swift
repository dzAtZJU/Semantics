//
//  SemWorldDataLayer.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/8/10.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import Foundation
import RealmSwift

struct SemWorldDataLayer {
    let realm: Realm
}

// MARK: Individual
extension SemWorldDataLayer {
    func queryOrCreateCurrentIndividual(userName: String) -> Individual {
        let userID = RealmSpace.queryCurrentUserID()!
        var individual = realm.object(ofType: Individual.self, forPrimaryKey: userID)
        if individual == nil {
            individual = Individual(id: userID, title: userName)
            try! realm.write {
                realm.add(individual!)
            }
        }
        
        return individual!
    }
    
    func queryCurrentIndividual() -> Individual? {
        let userID = RealmSpace.queryCurrentUserID()!
        let individual = realm.object(ofType: Individual.self, forPrimaryKey: userID)
        return individual
    }
    
    
    func queryAllIndividuals() -> Results<Individual> {
        realm.objects(Individual.self)
    }
    
    func dislike(inds: [String], forCondition condition: String) {
        let ind = queryCurrentIndividual()!
        var tmp: ConditionIndividuals! = ind.blockedIndividuals.first {
            $0.conditionId == condition
        }
        if tmp == nil {
            tmp = ConditionIndividuals(conditionId: condition)
            try! realm.write {
                ind.blockedIndividuals.append(tmp)
            }
            
        }
        let newOnes = Set(inds).filter {
            !tmp.individuals.contains($0)
        }

        try! realm.write {
            tmp.individuals.append(objectsIn: newOnes)
        }
        
        print("[dislike] \(ind.blockedIndividuals)")
    }
}

// MARK: Places
extension SemWorldDataLayer {
    func loadVisitedPlaces() -> [String] {
        queryCurrentIndividual()!.placeStory_List.map(by: \.placeID)
    }
    
    func queryPlace(_id: String) -> Place {
        realm.object(ofType: Place.self, forPrimaryKey: _id)!
    }
    
    func queryPlaces(_ids: [String]) -> Results<Place> {
        realm.objects(Place.self).filter("_id in %@", _ids)
    }
    
    func loadPlaceStory(placeID: String) -> PlaceStory? {
        queryCurrentIndividual()!.placeStory_List.first {
            $0.placeID == placeID
            }
    }
    
    func queryOrCreatePlace(_ uniquePlace: UniquePlace) -> Place {
        if let place = realm.object(ofType: Place.self, forPrimaryKey: uniquePlace.title) {
            return place
        } else {
            let newPlace = Place(title: uniquePlace.title, latitude: uniquePlace.latitude, longitude: uniquePlace.longitude)
            try! realm.write {
                self.realm.add(newPlace, update: .modified)
            }
            return newPlace
        }
    }
    
    func markVisited(placeID: String) {
        let ind = queryCurrentIndividual()!
        guard loadPlaceStory(placeID: placeID) == nil else {
            return
        }
        
        let placeStory = PlaceStory(placeID: placeID)
        try! realm.write {
            ind.placeStory_List.append(placeStory)
        }
    }
}

// MARK: PlaceStory
extension SemWorldDataLayer {
    func removeCondition(_ conditionID: String, from placeID: String) {
        let ind = queryCurrentIndividual()!
        let placeStory = ind.placeStory_List.first {
            $0.placeID == placeID
        }!
        guard !placeStory.perspectiveID_List.contains(conditionID) else {
            fatalError("The perspective \(conditionID) is already projected on \(placeStory.placeID)")
        }
        do {
            try! realm.write {
                placeStory.perspectiveID_List.append(conditionID)
            }
        }
    }
    
    func addCondition(_ conditionID: String, toPlace placeID: String) {
        let ind = queryCurrentIndividual()!
        let placeStory = ind.placeStory_List.first {
            $0.placeID == placeID
        }!
        
        guard let index = placeStory.perspectiveID_List.index(of: conditionID) else {
            fatalError("The perspective \(conditionID) is not on \(placeStory.placeID)")
        }
        do {
            try! realm.write {
                placeStory.perspectiveID_List.remove(at: index)
            }
        }
    }
}

// MARK: ConditionRank
extension SemWorldDataLayer {
    func createConditionRank_IfNone(conditionID: String) {
        guard queryConditionRank(conditionID: conditionID) == nil else {
            return
        }
        
        let ind = queryCurrentIndividual()!
        try! realm.write {
            ind.conditionRank_List.append(ConditionRank(conditionID: conditionID))
        }
    }
    
    func addPlace(_ placeID: String, toConditionRank conditionID: String) {
        guard let conditionRank = queryConditionRank(conditionID: conditionID) else {
            fatalError()
        }
        
        guard nil == conditionRank.placeScore_List.firstIndex(where: {
            $0.placeID == placeID
        }) else {
            fatalError()
        }
        
        let lowerestScore = conditionRank.placeScore_List.last?.score ?? 0
        try! realm.write {
            conditionRank.placeScore_List.append(PlaceScore(placeID: placeID, score: lowerestScore))
        }
    }
    
    func removePlace(_ placeID: String, fromConditionRank conditionID: String) {
        guard let conditionRank = queryConditionRank(conditionID: conditionID) else {
            fatalError()
        }
        
        guard let index = conditionRank.placeScore_List.firstIndex(where: {
            $0.placeID == placeID
        }) else {
            fatalError()
        }
        
        try! realm.write {
            conditionRank.placeScore_List.remove(at: index)
        }
    }
    
    func queryConditionRank(conditionID: String) -> ConditionRank? {
        let ind = queryCurrentIndividual()!
        return ind.conditionRank_List.first {
            $0.conditionID == conditionID
        }
    }
    
    func queryPrivatePerspectives() -> [String] {
        let ind = queryCurrentIndividual()!
        return ind.conditionRank_List.map {
            $0.conditionID
        }
    }
}

// Condition
extension SemWorldDataLayer {
    func createCondition_IfNone(id id_: String) {
        do {
            realm.add(Condition(id: id_), update: .modified)
        }
    }
}
