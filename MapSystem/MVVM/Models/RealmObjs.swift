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
    
    let visitors = LinkingObjects(fromType: Individual.self, property: "visitedPlaces")
    
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
    
    let ranks = LinkingObjects(fromType: ConditionRank.self, property: "condition")
    
    convenience init(title title_: String) {
        self.init()
        title = title_
    }
}

class PlaceScore: SyncedObject {
    @objc dynamic var partitionKey: String = RealmSpace.partitionValue
    
    @objc dynamic var place: Place?
    @objc dynamic var score = 0
    
    
    convenience init(place place_: Place, score score_: Int) {
        self.init()
        place = place_
        score = score_
    }
}

class ConditionRank: SyncedObject {
    @objc dynamic var partitionKey: String = RealmSpace.partitionValue
    
    @objc dynamic var condition: Condition?
    
    var placeScoreList = List<PlaceScore>()
    
    convenience init(condition condition_: Condition, placeScores: [PlaceScore] = []) {
        self.init()
        condition = condition_
        placeScoreList.append(objectsIn: placeScores)
    }
}

class PlaceStory: SyncedObject {
    @objc dynamic var place: Place?
    @objc dynamic var state = 1
    @objc dynamic var individual: Individual?
}

class Individual: Object {
    @objc dynamic var _id: String = ""
    @objc dynamic var partitionKey: String = RealmSpace.partitionValue
    
    @objc dynamic var title = ""
    
    let conditionsRank = List<ConditionRank>()
    
    let friends = List<Individual>()
    
    let visitedPlaces = List<Place>()
    
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
