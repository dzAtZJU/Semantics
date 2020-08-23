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
}

// MARK: Run Iteration
extension SemWorldDataLayer {
    struct IterationQuery {
        struct Condition {
            let _id: ObjectId
            let `operator`: NextOperator
        }
        
        let placeId: ObjectId
        let conditions: [Condition]
    }
    
    struct CanditatePlaces {
        lazy var placeId2Conditions = [ObjectId: Conditions]()
    }
    
    struct Conditions {
        lazy var conditionId2Condition = [ObjectId: ConditionInfo]()
    }
    
    
    struct ConditionInfo {
        lazy var friends = [String]()
    }
    
    enum IterationQueryReslut {
        case none
        case ok(CanditatePlaces)
    }
    
    
    func runNextIteration(query: IterationQuery, completion: @escaping (IterationQueryReslut) -> Void) {
        let individual = self.queryCurrentIndividual()
        let friends = individual!.friends
        let placeIdInQuery = query.placeId
        let conditionsInQuery = query.conditions
        let betterConditionsInQuery = conditionsInQuery.filter {
            $0.operator == .better
        }
        var canditatePlaces = CanditatePlaces()
        for friend in friends {
            var s = friend.title
            for rank in friend.conditionsRank {
                s += " " + rank.condition!.title
                for placeScore in rank.placeScoreList {
                    s += " " + placeScore.place!.title
                }
            }
            print("friend \(s)")
            
            for rank in friend.conditionsRank {
                guard let condition = betterConditionsInQuery.first(where: {
                    $0._id == rank.condition!._id
                }) else {
                    continue
                }
                
                let placeScoreList =  rank.placeScoreList
                let index: Int! = placeScoreList.firstIndex {
                    $0.place!._id == placeIdInQuery
                }
                guard index != nil, index > placeScoreList.startIndex else {
                    continue
                }
                let canditatePlaceScore = placeScoreList[placeScoreList.index(before: index)]
                let canditatePlaceId = canditatePlaceScore.place!._id
                canditatePlaces.placeId2Conditions[canditatePlaceId, default: Conditions()].conditionId2Condition[condition._id, default: ConditionInfo()].friends.append(friend._id)
            }
        }
        
        var removedIds = [ObjectId]()
        for (placeId, var conditions) in canditatePlaces.placeId2Conditions {
            guard conditions.conditionId2Condition.count == betterConditionsInQuery.count else {
                removedIds.append(placeId)
                continue
            }
        }
        canditatePlaces.placeId2Conditions.removeAll(keys: removedIds)
        if canditatePlaces.placeId2Conditions.isEmpty {
            completion(.none)
        } else {
            completion(.ok(canditatePlaces))
        }
    }
}

// MARK: Places
extension SemWorldDataLayer {
    func queryVisitedPlaces() -> [Place] {
        queryCurrentIndividual()!.placeStoryList.compactMap(by: \.place)
    }
    
    func queryPlace(_id: ObjectId) -> Place {
        realm.object(ofType: Place.self, forPrimaryKey: _id)!
    }
    
    func queryPlaces(_ids: [ObjectId]) -> Results<Place> {
        realm.objects(Place.self).filter("_id in %@", _ids)
    }
    
    func queryPlaceStory(placeId: ObjectId) -> PlaceStory {
        queryCurrentIndividual()!.placeStoryList.first {
            $0.place!._id == placeId
            }!
    }
    
    func queryOrCreatePlace(_ uniquePlace: UniquePlace) -> Place {
        let places = realm.objects(Place.self).filter("latitude = %@ AND longitude = %@ AND title = %@", uniquePlace.latitude, uniquePlace.longitude, uniquePlace.title)
        if places.isEmpty {
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
        let placeStory = PlaceStory()
        placeStory.individual = ind
        placeStory.place = place
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
}

// MARK: Mock
extension SemWorldDataLayer {
    func createUserData(name: String) {
        let ind = queryOrCreateCurrentIndividual(userName: name)
        let conditions = realm.objects(Condition.self)
        let rank1 = ConditionRank(condition: conditions[0])
        let rank2 = ConditionRank(condition: conditions[1])
        let rank3 = ConditionRank(condition: conditions[2])
        try! realm.write {
            ind.conditionsRank.append(objectsIn: [rank1, rank2, rank3])
        }
    }
    
    func createAppData() {
        guard realm.objects(Condition.self).isEmpty else {
            return
        }
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
                return PlaceScore(place: place, score: score)
            }
            let rank1 = ConditionRank(condition: conditions[2], placeScores: Array(placeScores1).sorted(by: { (a, b) in
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
                return PlaceScore(place: place, score: score)
            }
            let rank2 = ConditionRank(condition: conditions[0], placeScores: Array(placeScores2).sorted(by: { (a, b) in
                a.score < b.score
            }))
            try! realm.write {
                individual.conditionsRank.append(objectsIn: [rank1, rank2])
            }
            var s = individual.title
            for rank in individual.conditionsRank {
                s += " " + rank.condition!.title
                for placeScore in rank.placeScoreList {
                    s += " " + placeScore.place!.title
                }
            }
            print(s)
        }
    }
    
}

//mongodb+srv://paper:<password>@cluster0.3ium9.mongodb.net/test
