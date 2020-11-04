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
    
    @objc dynamic var longitude: Double = 0
    @objc dynamic var latitude: Double = 0
    
    @objc dynamic var uniqueness: Int = 0
    
    convenience init(title: String, latitude: Double, longitude: Double, uniqueness: Int) {
        self.init()
        self.partitionKey = RealmSpace.partitionValue
        self._id = title
        self.title = title
        self.latitude = latitude
        self.longitude = longitude
        self.uniqueness = uniqueness
    }
    
    override static func primaryKey() -> String? {
        "_id"
    }
}

class Condition: Object {
    @objc dynamic var _id = ""
    @objc dynamic var partitionKey = ""
    
    convenience init(id id_: String) {
        self.init()
        _id = id_
        partitionKey = RealmSpace.partitionValue
    }
    
    override static func primaryKey() -> String? {
        "_id"
    }
}

class Individual: Object {
    @objc dynamic var _id: String = ""
    @objc dynamic var partitionKey: String = RealmSpace.queryCurrentUserID()!
    
    @objc dynamic var title = ""
    
    let placeStory_List = List<PlaceStory>()
    
    let conditionRank_List = List<ConditionRank>()
    
    let blockedIndividuals = List<ConditionIndividuals>()
    
    convenience init(id id_: String, title title_: String) {
        self.init()
        _id = id_
        title = title_
    }
    
    override static func primaryKey() -> String? {
        "_id"
    }
}

class PlaceStory: EmbeddedObject {
    let owner = LinkingObjects(fromType: Individual.self, property: "placeStory_List")
    
    @objc dynamic var placeID = ""
    
    @objc dynamic var state = 1
    
    let conditionID_List = List<String>()
    
    let perspectiveInterpretation_List = List<PerspectiveInterpretation>()
    
    convenience init(placeID placeID_: String) {
        self.init()
        placeID = placeID_
    }
}

class PerspectiveInterpretation: EmbeddedObject {
    @objc dynamic var perspectiveID = ""
    
    @objc dynamic var fileData = ""
    
    convenience init(perspectiveID perspectiveID_: String, fileData fileData_: String) {
        self.init()
        perspectiveID = perspectiveID_
        fileData = fileData_
    }
}

class ConditionRank: EmbeddedObject {
    let owner = LinkingObjects(fromType: Individual.self, property: "conditionRank_List")
    
    @objc dynamic var conditionID = ""
    
    let placeScore_List = List<PlaceScore>()
    
    convenience init(conditionID conditionID_: String, placeScores: [PlaceScore] = []) {
        self.init()
        conditionID = conditionID_
        placeScore_List.append(objectsIn: placeScores)
    }
}

class PlaceScore: EmbeddedObject {
    let owner = LinkingObjects(fromType: ConditionRank.self, property: "placeScore_List")
    
    @objc dynamic var placeID = ""
    @objc dynamic var score = 0
    
    convenience init(placeID placeID_: String, score score_: Int) {
        self.init()
        placeID = placeID_
        score = score_
    }
}

class ConditionIndividuals: EmbeddedObject {
    let owner = LinkingObjects(fromType: Individual.self, property: "blockedIndividuals")
    
    @objc dynamic var conditionId = ""
    let individuals = List<String>()
    
    convenience init(conditionId conditionId_: String) {
        self.init()
        conditionId = conditionId_
    }
}
