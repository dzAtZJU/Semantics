//
//  RealmObjs.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/8/10.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//
import RealmSwift

class SyncedObject: Object {
    @objc dynamic var partitionKey = ""
    
    @objc dynamic var _id =  ObjectId.generate()
    
    override static func primaryKey() -> String? {
        "_id"
    }
}

class Place: Object {
    @objc dynamic var _id = ""
    @objc dynamic var partitionKey = ""
    
    @objc dynamic var title = ""
    
    @objc dynamic var latitude: Double = 0
    @objc dynamic var longitude: Double = 0
    
    convenience init(title: String, latitude: Double, longitude: Double) {
        self.init()
        self.partitionKey = RealmSpace.partitionValue
        self._id = title
        self.title = title
        self.latitude = latitude
        self.longitude = longitude
    }
    
    override static func primaryKey() -> String? {
        "_id"
    }
}

class Condition: Object {
    @objc dynamic var _id = ""
    @objc dynamic var partitionKey = ""
    @objc dynamic var title = ""
    
    convenience init(title title_: String) {
        self.init()
        _id = title
        partitionKey = RealmSpace.partitionValue
        title = title_
    }
    
    override static func primaryKey() -> String? {
        "_id"
    }
}

class PlaceScore: Object {
    @objc dynamic var _id = ""
    @objc dynamic var partitionKey = ""
    @objc dynamic var placeId = ""
    @objc dynamic var score = 0
    let conditionRank = LinkingObjects(fromType: ConditionRank.self, property: "placeScoreList")
    
    convenience init(conditionId: String, placeId placeId_: String, score score_: Int) {
        self.init()
        _id = RealmSpace.queryCurrentUserID()! + " " + placeId_ + " " + conditionId
        partitionKey = RealmSpace.queryCurrentUserID()!
        placeId = placeId_
        score = score_
    }
    
    override static func primaryKey() -> String? {
        "_id"
    }
}

class ConditionRank: SyncedObject {
    @objc dynamic var ownerId = ""
    
    @objc dynamic var conditionId = ""
    
    let placeScoreList = List<PlaceScore>()
    
    convenience init(ownerId ownerId_: String, conditionId conditionId_: String, placeScores: [PlaceScore] = []) {
        self.init()
        super.partitionKey = RealmSpace.queryCurrentUserID()!
        ownerId = ownerId_
        conditionId = conditionId_
        placeScoreList.append(objectsIn: placeScores)
    }
    
    override static func indexedProperties() -> [String] {
        ["ownerId", "conditionId"]
    }
}

class PlaceStory: SyncedObject {
    @objc dynamic var placeId: String?
    @objc dynamic var state = 1
    @objc dynamic var individual: Individual?
    
    convenience init(individual individual_: Individual, placeId placeId_: String) {
        self.init()
        super.partitionKey = RealmSpace.queryCurrentUserID()!
        individual = individual_
        placeId = placeId_
    }
}

class ConditionIndividuals: EmbeddedObject {
    @objc dynamic var conditionId = ""
    let individuals = List<String>()
    
    convenience init(conditionId conditionId_: String) {
        self.init()
        conditionId = conditionId_
    }
}

class Individual: Object {
    @objc dynamic var _id: String = ""
    @objc dynamic var partitionKey: String = RealmSpace.queryCurrentUserID()!
    
    @objc dynamic var title = ""
    
    let conditionsRank = List<ConditionRank>()
    
    let blockedIndividuals = List<ConditionIndividuals>()
    
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
