//
//  RealmObjs.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/8/10.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//
import RealmSwift

class SyncedObject: Object {
    @objc dynamic var _id =  ObjectId.generate()
    
    override static func primaryKey() -> String? {
        "_id"
    }
}

class Place: SyncedObject {
    @objc dynamic var partitionKey: String = RealmSpace.partitionValue
    
    @objc dynamic var title = ""
    
    @objc dynamic var latitude: Double = 0
    @objc dynamic var longitude: Double = 0
    
    convenience init(title: String, latitude: Double, longitude: Double) {
        self.init()
        self.title = title
        self.latitude = latitude
        self.longitude = longitude
    }
    
    override static func indexedProperties() -> [String] {
        []
    }
    
    override static func ignoredProperties() -> [String] {
        []
    }
    
    
}

class Condition: SyncedObject {
    @objc dynamic var partitionKey: String = RealmSpace.partitionValue
    
    @objc dynamic var title = ""
    
    convenience init(title title_: String) {
        self.init()
        title = title_
    }
}

class PlaceScore: SyncedObject {
    @objc dynamic var placeId: ObjectId?
    @objc dynamic var score = 0
    
    convenience init(placeId placeId_: ObjectId, score score_: Int) {
        self.init()
        placeId = placeId_
        score = score_
    }
}

class ConditionRank: SyncedObject {
    @objc dynamic var partitionKey: String = RealmSpace.partitionValue
    
    @objc dynamic var ownerId: String?
    
    @objc dynamic var conditionId: ObjectId?
    
    var placeScoreList = List<PlaceScore>()
    
    convenience init(ownerId ownerId_: String, conditionId conditionId_: ObjectId, placeScores: [PlaceScore] = []) {
        self.init()
        ownerId = ownerId_
        conditionId = conditionId_
        placeScoreList.append(objectsIn: placeScores)
    }
}

class PlaceStory: SyncedObject {
    @objc dynamic var placeId: ObjectId?
    @objc dynamic var state = 1
    @objc dynamic var individual: Individual?
    
    convenience init(individual individual_: Individual, placeId placeId_: ObjectId) {
        self.init()
        individual = individual_
        placeId = placeId_
    }
}

class Individual: Object {
    @objc dynamic var _id: String = ""
    @objc dynamic var partitionKey: String = RealmSpace.partitionValue
    
    @objc dynamic var title = ""
    
    let conditionsRank = List<ConditionRank>()
    
    let friends = List<Individual>()
    
    let blockedIndividuals = List<String>()
    
    let placeStoryList = LinkingObjects(fromType: PlaceStory.self, property: "individual")
    
    convenience init(id id_: String, title title_: String) {
        self.init()
        _id = id_
        title = title_
    }
    
    override static func primaryKey() -> String? {
        "_id"
    }
}
