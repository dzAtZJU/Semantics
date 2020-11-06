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
    
    //TODO
    func queryOrCreatePlace(_ uniquePlace: UniquePlace) -> Place {
//        if let place = realm.object(ofType: Place.self, forPrimaryKey: uniquePlace.title) {
//            return place
//        } else {
            let uniqueness = uniquePlace.title.contains("领事馆") ? Uniqueness.unique.rawValue : Uniqueness.ordinary.rawValue
            let newPlace = Place(title: uniquePlace.title, latitude: uniquePlace.latitude, longitude: uniquePlace.longitude, uniqueness: uniqueness)
            try! realm.write {
                self.realm.add(newPlace, update: .modified)
            }
            return newPlace
//        }
    }
    
    func markVisited(placeID: String) {
        let ind = queryCurrentIndividual()!
        guard queryPlaceStory(placeID: placeID) == nil else {
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
    func queryPlaceStory(placeID: String) -> PlaceStory? {
        queryCurrentIndividual()!.placeStory_List.first {
            $0.placeID == placeID
            }
    }
    
    func addCondition(_ conditionID: String, toPlace placeID: String) {
        let ind = queryCurrentIndividual()!
        let placeStory = ind.placeStory_List.first {
            $0.placeID == placeID
        }!
        guard !placeStory.conditionID_List.contains(conditionID) else {
            fatalError("The perspective \(conditionID) is already projected on \(placeStory.placeID)")
        }
        
        
        placeStory.conditionID_List.append(conditionID)
    }
    
    func removeCondition(_ conditionID: String, fromPlace placeID: String) {
        let ind = queryCurrentIndividual()!
        let placeStory = ind.placeStory_List.first {
            $0.placeID == placeID
        }!
        
        guard let index = placeStory.conditionID_List.index(of: conditionID) else {
            fatalError("The perspective \(conditionID) is not on \(placeStory.placeID)")
        }
        
        placeStory.conditionID_List.remove(at: index)
    }
    
    func queryConditionIDs(forPlace placeID: String) -> [String] {
        guard let placeStory = queryPlaceStory(placeID: placeID) else {
            fatalError()
        }
        
        return try! placeStory.conditionID_List.map { (id) throws -> String in
            id
        }
    }
    
    func addPerspective(_ perspectiveID: String, fileData: Data, toPlace placeID: String) {
        let ind = queryCurrentIndividual()!
        let placeStory = ind.placeStory_List.first {
            $0.placeID == placeID
        }!
        guard !placeStory.perspectiveInterpretation_List.contains(where: { (item) -> Bool in
            item.perspectiveID == perspectiveID
        }) else {
            fatalError("The perspective \(perspectiveID) is already projected on \(placeStory.placeID)")
        }


        placeStory.perspectiveInterpretation_List.append(PerspectiveInterpretation(perspectiveID: perspectiveID, fileData: fileData))
    }
    
    func removePerspective(_ perspectiveID: String, fromPlace placeID: String) {
        let ind = queryCurrentIndividual()!
        let placeStory = ind.placeStory_List.first {
            $0.placeID == placeID
        }!

        guard let index = placeStory.perspectiveInterpretation_List.firstIndex(where: { (item) -> Bool in
            item.perspectiveID == perspectiveID
        }) else {
            fatalError("The perspective \(perspectiveID) is not on \(placeStory.placeID)")
        }

        placeStory.perspectiveInterpretation_List.remove(at: index)
    }
    
    func queryPerspectiveIDs(forPlace placeID: String) -> [String] {
        guard let placeStory = queryPlaceStory(placeID: placeID) else {
            fatalError()
        }
        
        return try! placeStory.perspectiveInterpretation_List.map { (item) throws -> String in
            item.perspectiveID
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
        ind.conditionRank_List.append(ConditionRank(conditionID: conditionID))
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
        
        conditionRank.placeScore_List.append(PlaceScore(placeID: placeID, score: lowerestScore))
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
        
        conditionRank.placeScore_List.remove(at: index)
    }
    
    func queryConditionRank(conditionID: String) -> ConditionRank? {
        let ind = queryCurrentIndividual()!
        return ind.conditionRank_List.first {
            $0.conditionID == conditionID
        }
    }
    
    func loadConditionRank_List() -> List<ConditionRank> {
        let ind = queryCurrentIndividual()!
        return ind.conditionRank_List
    }
    
    func queryPrivateConditions() -> [String] {
        let ind = queryCurrentIndividual()!
        return ind.conditionRank_List.map {
            $0.conditionID
        }
    }
}

// Condition
extension SemWorldDataLayer {
    func createCondition_IfNone(id id_: String) {
        try! realm.write {
            realm.add(Condition(id: id_), update: .modified)
        }
    }
}
