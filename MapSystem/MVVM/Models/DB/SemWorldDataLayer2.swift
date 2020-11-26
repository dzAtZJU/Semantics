import RealmSwift

extension Realm {
    func projectCondition(_ conditionID: String, on placeID: String) {
        try! write {
            createConditionRank_IfNone(conditionID: conditionID)
            addCondition(conditionID, toPlace: placeID)
            addPlace(placeID, toConditionRank: conditionID)
        }
    }
    
    func withdrawCondition(_ conditionID: String, from placeID: String) {
        try! write {
            removeCondition(conditionID, fromPlace: placeID)
            removePlace(placeID, fromConditionRank: conditionID)
        }
    }
    
    func queryConditionRank_List(havingPlace placeID: String) -> [ConditionRank] {
        guard let placeStory = queryPlaceStory(placeID: placeID) else {
            fatalError()
        }
        
        let placeperspectives = placeStory.conditionID_List
        return try! loadConditionRank_List().filter { (conditionRank: ConditionRank) throws -> Bool in
            placeperspectives.contains(conditionRank.conditionID)
        }
    }
    
    func projectPerspective(_ perspectiveID: String, fileData: Data, on placeID: String) {
        try! write {
            addPerspective(perspectiveID, fileData: fileData, toPlace: placeID)
        }
    }
    
    func withdrawPerspective(_ perspectiveID: String, from placeID: String) {
        try! write {
            removePerspective(perspectiveID, fromPlace: placeID)
        }
    }
}
