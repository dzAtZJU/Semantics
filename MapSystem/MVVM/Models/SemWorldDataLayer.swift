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
    func queryVisitedPlaces() -> [String] {
        queryCurrentIndividual()!.placeStoryList.compactMap(by: \.placeId)
    }
    
    func queryPlace(_id: String) -> Place {
        realm.object(ofType: Place.self, forPrimaryKey: _id)!
    }
    
    func queryPlaces(_ids: [String]) -> Results<Place> {
        realm.objects(Place.self).filter("_id in %@", _ids)
    }
    
    func queryPlaceStory(placeId: String) -> PlaceStory {
        queryCurrentIndividual()!.placeStoryList.first {
            $0.placeId == placeId
            }!
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
    
    func markVisited(place: Place, completion: (Place) -> Void) {
        
        let ind = queryCurrentIndividual()!
        let placeStory = PlaceStory(individual: ind, placeId: place._id)
        try! realm.write {
            self.realm.add(placeStory)
        }
        
        completion(place.freeze())
    }
}

extension SemWorldDataLayer {
    func queryPlaceSocre(_id: String) -> PlaceScore? {
        realm.object(ofType: PlaceScore.self, forPrimaryKey: _id)
    }
    
    func queryConditionRank(_id: ObjectId) -> ConditionRank {
        realm.object(ofType: ConditionRank.self, forPrimaryKey: _id)!
    }
}

extension SemWorldDataLayer {
    func queryConditions() -> [String] {
        realm.objects(Condition.self).map(by: \._id)
    }
    
    func queryCondition(_id: String) -> Condition {
        realm.object(ofType: Condition.self, forPrimaryKey: _id)!
    }
}

// MARK: Mock
extension SemWorldDataLayer {
    func createExtraConditionRanks(allConditionIds: [String]) {
        let ind = queryCurrentIndividual()!
        
        let existingIds = ind.conditionsRank.map { $0.conditionId }
        let newItems = allConditionIds.filter {
            !existingIds.contains($0)
        }.map {
            ConditionRank(ownerId: ind._id, conditionId: $0)
        }
        
        try! realm.write {
            ind.conditionsRank.append(objectsIn: newItems)
        }
    }
}
