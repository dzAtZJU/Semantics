//
//  SemWorldDataLayer.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/8/10.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import Foundation
import RealmSwift

class SemWorldDataLayer {
    convenience init(partitionValue: String, space: RealmSpace = RealmSpace.shared) {
        self.init(realm: space.newRealm(partitionValue))
    }
    
    let realm: Realm
    init(realm realm_: Realm) {
        realm = realm_
    }
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
    
    func block(inds: [ObjectId], forCondition: ObjectId) {
        
    }
}

// MARK: Places
extension SemWorldDataLayer {
    func queryVisitedPlaces() -> Results<Place> {
        queryPlaces(_ids: queryCurrentIndividual()!.placeStoryList.compactMap(by: \.placeId))
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
                self.realm.add(newPlace)
            }
            return newPlace
        }
        if places.count > 1 {
            fatalError("Duplicate Place \(places)")
        }
        return places.first!
    }
    
    func markVisited(uniquePlace: UniquePlace, completion: (Place) -> Void) {
        let place = queryOrCreatePlace(uniquePlace)
        let ind = queryCurrentIndividual()!
        let placeStory = PlaceStory(individual: ind, placeId: place._id)
        try! realm.write {
            self.realm.add(placeStory)
        }
        
        completion(place)
    }
}

extension SemWorldDataLayer {
    func queryPlaceSocre(_id: ObjectId) -> PlaceScore {
        realm.object(ofType: PlaceScore.self, forPrimaryKey: _id)!
    }
}

extension SemWorldDataLayer {
    func queryConditionRank(_id: ObjectId) -> ConditionRank {
        realm.object(ofType: ConditionRank.self, forPrimaryKey: _id)!
    }
    
    func queryCondition(_id: ObjectId) -> Condition {
        realm.object(ofType: Condition.self, forPrimaryKey: _id)!
    }
}

// MARK: Mock
extension SemWorldDataLayer {
    func createUserData(name: String) {
        let ind = queryOrCreateCurrentIndividual(userName: name)
        let conditions = realm.objects(Condition.self)
        let rank1 = ConditionRank(ownerId: ind._id, conditionId: conditions[0]._id)
        let rank2 = ConditionRank(ownerId: ind._id, conditionId: conditions[1]._id)
        let rank3 = ConditionRank(ownerId: ind._id, conditionId: conditions[2]._id)
        try! realm.write {
            ind.conditionsRank.append(objectsIn: [rank1, rank2, rank3])
        }
    }
    
    func createAppData() {
        guard realm.objects(Condition.self).isEmpty else {
            return
        }
        print("createAppData should create")
        //        guard queryVisitedPlaces().count == 0 else {
        //            return
        //        }
        
        //        let places = [
        //            Place(title: "Tims-上滨生活广场", latitude: 31.260_402, longitude: 121.503_985),
        //            Place(title: "Tims-大学路", latitude: 31.304_107, longitude: 121.508_546),
        //            Place(title: "Pacific-瑞虹月亮湾", latitude: 31.264594, longitude: 121.498751),
        //            Place(title: "Tims-香溢花城", latitude: 31.254618, longitude: 121.432538),
        //            Place(title: "1984", latitude: 31.208482, longitude: 121.442764),
        //            Place(title: "钟书阁-芮欧", latitude: 31.223325, longitude: 121.447489)
        //        ]
        let conditions = [
            Condition(title: "空间感"),
            Condition(title: "网络"),
            Condition(title: "卫生间")
        ]
        try! realm.write {
            self.realm.add(conditions)
        }
        //        let placeScores1 = places.map { place -> PlaceScore in
        //            var score = 5
        //            switch place.title {
        //            case "Tims-大学路":
        //                score = 0
        //            case "1984":
        //                score = 1
        //            case "Tims-上滨生活广场":
        //                score = 2
        //            case "Tims-香溢花城":
        //                score = 2
        //            case "Pacific-瑞虹月亮湾":
        //                score = 3
        //            default:
        //                break
        //            }
        //            return PlaceScore(place: place, score: score)
        //        }
        
        //        Array(placeScores1).sorted(by: { (a, b) in
        //            a.score < b.score
        //        }))
        //
        
        //
        //        let placeScores3 = places.map { place -> PlaceScore in
        //            var score = 5
        //            switch place.title {
        //            case "Tims-上滨生活广场":
        //                score = 0
        //            case "Pacific-瑞虹月亮湾":
        //                score = 1
        //            case "1984":
        //                score = 2
        //            case "Tims-香溢花城":
        //                score = 3
        //            case "Tims-大学路":
        //                score = 4
        //            default:
        //                break
        //            }
        //            return PlaceScore(place: place, score: score)
        //        }
        //        Array(placeScores3).sorted(by: { (a, b) in
        //            a.score < b.score
        //        }))

        
        //        let newInd = Individual(id: "5f33045a7ece30732bab9299", title: "Weiran")
        //        try! realm.write {
        //            self.realm.add(newInd)
        //        }
        
        //        let inds = self.queryAllIndividuals()
        //        var tag = 0
        //        for individual in inds {
        //            guard individual._id != ind._id else { continue }
        //            self.createMoccDataFor(individual, tag: tag, places: places, conditions: conditions)
        //            tag += 1
        //            try! self.realm.write {
        //                ind.friends.append(individual)
        //            }
        //        }
    }
    
    func createMoccDataFor(_ individual: Individual, tag: Int, places: [Place], conditions: [Condition]) {
        if tag == 0 {
            let placeScores1 = places.compactMap { place -> PlaceScore? in
                var score = 5
                switch place.title {
                case "钟书阁-芮欧":
                    score = 0
                case "Pacific-瑞虹月亮湾":
                    score = 1
                default:
                    return nil
                }
                return PlaceScore(placeId: place._id, score: score)
            }
            let rank1 = ConditionRank(ownerId: individual._id, conditionId: conditions[2]._id, placeScores: Array(placeScores1).sorted(by: { (a, b) in
                a.score < b.score
            }))
            
            let placeScores2 = places.compactMap { place -> PlaceScore? in
                var score = 5
                switch place.title {
                case "钟书阁-芮欧":
                    score = 0
                case "Pacific-瑞虹月亮湾":
                    score = 1
                default:
                    return nil
                }
                return PlaceScore(placeId: place._id, score: score)
            }
            let rank2 = ConditionRank(ownerId: individual._id, conditionId: conditions[0]._id, placeScores: Array(placeScores2).sorted(by: { (a, b) in
                a.score < b.score
            }))
            try! realm.write {
                individual.conditionsRank.append(objectsIn: [rank1, rank2])
            }
        }
    }
    
}

//mongodb+srv://paper:<password>@cluster0.3ium9.mongodb.net/test
