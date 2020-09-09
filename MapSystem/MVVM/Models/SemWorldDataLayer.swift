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
        let userID = RealmSpace.shared.queryCurrentUserID()!
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
        let userID = RealmSpace.shared.queryCurrentUserID()!
        let individual = realm.object(ofType: Individual.self, forPrimaryKey: userID)
        return individual
    }
    
    
    func queryAllIndividuals() -> Results<Individual> {
        realm.objects(Individual.self)
    }
    
    func dislike(inds: [String], forCondition condition: ObjectId) {
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
    func queryVisitedPlaces() -> [ObjectId] {
        queryCurrentIndividual()!.placeStoryList.compactMap(by: \.placeId)
    }
    
    func queryPlace(_id: ObjectId) -> Place {
        realm.object(ofType: Place.self, forPrimaryKey: _id)!
    }
    
    func queryPlaces(_ids: [ObjectId]) -> Results<Place> {
        realm.objects(Place.self).filter("_id in %@", _ids)
    }
    
    func queryPlaceStory(placeId: ObjectId) -> PlaceStory {
        queryCurrentIndividual()!.placeStoryList.first {
            $0.placeId == placeId
            }!
    }
    
    func queryOrCreatePlace(_ uniquePlace: UniquePlace) -> Place {
        let places = realm.objects(Place.self).filter("latitude == %d AND longitude == %d AND title == %@", uniquePlace.latitude, uniquePlace.longitude, uniquePlace.title)
        if places.isEmpty {
            print("queryOrCreatePlace should create")
            let newPlace = Place(title: uniquePlace.title, latitude: uniquePlace.latitude, longitude: uniquePlace.longitude)
            try! realm.write {
                self.realm.add(newPlace, update: .modified)
            }
            return newPlace
        }
        if places.count > 1 {
            fatalError("Duplicate Place \(places)")
        }
        return places.first!
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
    func queryPlaceSocre(_id: ObjectId) -> PlaceScore {
        realm.object(ofType: PlaceScore.self, forPrimaryKey: _id)!
    }
    
    func queryConditionRank(_id: ObjectId) -> ConditionRank {
        realm.object(ofType: ConditionRank.self, forPrimaryKey: _id)!
    }
}

extension SemWorldDataLayer {
    func queryConditions() -> [ObjectId] {
        realm.objects(Condition.self).map(by: \._id)
    }
    
    func queryCondition(_id: ObjectId) -> Condition {
        realm.object(ofType: Condition.self, forPrimaryKey: _id)!
    }
}

// MARK: Mock
extension SemWorldDataLayer {
    func createUserData(name: String, conditionIds: [ObjectId]) {
        let ind = queryOrCreateCurrentIndividual(userName: name)
        guard !conditionIds.isEmpty else {
            return
        }
        if ind.conditionsRank.isEmpty {
            let rank1 = ConditionRank(ownerId: ind._id, conditionId: conditionIds[0])
            let rank2 = ConditionRank(ownerId: ind._id, conditionId: conditionIds[1])
            let rank3 = ConditionRank(ownerId: ind._id, conditionId: conditionIds[2])
            try! realm.write {
                ind.conditionsRank.append(objectsIn: [rank1, rank2, rank3])
            }
        }
    }
}
