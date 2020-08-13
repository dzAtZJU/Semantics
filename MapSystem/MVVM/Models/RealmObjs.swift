//
//  RealmObjs.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/8/10.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//
import RealmSwift

class Place: Object {
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

class Condition: Object {
    @objc dynamic var title = ""
    
    let ranks = LinkingObjects(fromType: RankByCondition.self, property: "condition")
}

class PlaceScore: Object {
    @objc dynamic var place: Place?
    @objc dynamic var score = 0
}

class RankByCondition: Object {
    @objc dynamic var condition: Condition?
    
    let placeScoreList = List<PlaceScore>()
}

class Individual: Object {
    @objc dynamic var title = ""
    
    let rankByConditionList = List<RankByCondition>()
    
    let friends = List<Individual>()
    
    @objc dynamic var partitionKey: String = "Public"
    
    @objc dynamic var id: String = ""
    override static func primaryKey() -> String? {
        "id"
    }
    
    convenience init(id id_: String, title title_: String) {
        self.init()
        id = id_
        title = title_
    }
}
