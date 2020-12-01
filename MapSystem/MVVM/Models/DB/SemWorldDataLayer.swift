import Foundation
import RealmSwift

// MARK: Individual
extension Realm {
    func queryOrCreateCurrentIndividual(userName: String) -> Individual {
        var individual = object(ofType: Individual.self, forPrimaryKey: RealmSpace.userID)
        if individual == nil {
            individual = Individual(id: RealmSpace.userID, title: userName)
            try! write {
                add(individual!)
            }
        }
        
        return individual!
    }
    
    func modifyName(_ name: String?) {
        let ind = queryCurrentIndividual()!
        try! write {
            ind.title = name
        }
    }

    func modifyAvatar(_ avatar: Data?) {
        let ind = queryCurrentIndividual()!
        try! write {
            ind.avatar = avatar
        }
    }
    
    func queryCurrentIndividual() -> Individual? {
        let userID = RealmSpace.userID
        let individual = object(ofType: Individual.self, forPrimaryKey: userID)
        return individual
    }
    
    func queryIndividual(_ userID: String) -> Individual? {
        let individual = object(ofType: Individual.self, forPrimaryKey: userID)
        return individual
    }
    
    func queryAllIndividuals() -> Results<Individual> {
        objects(Individual.self)
    }
    
    func queryPartners() -> List<String> {
        queryCurrentIndividual()!.partner_List
    }
    
    func dislike(inds: [String], forCondition condition: String) {
        let ind = queryCurrentIndividual()!
        var tmp: ConditionIndividuals! = ind.blockedIndividuals.first {
            $0.conditionId == condition
        }
        if tmp == nil {
            tmp = ConditionIndividuals(conditionId: condition)
            try! write {
                ind.blockedIndividuals.append(tmp)
            }
            
        }
        let newOnes = Set(inds).filter {
            !tmp.individuals.contains($0)
        }

        try! write {
            tmp.individuals.append(objectsIn: newOnes)
        }
        
        print("[dislike] \(ind.blockedIndividuals)")
    }
}

// MARK: Places
extension Realm {
    func loadUserPlaceIDsRequire(publicConcept: Bool, privateConcept: Bool, userID: String = RealmSpace.userID) -> [String] {
        try! queryIndividual(userID)!.placeStory_List.filter { (story: PlaceStory) throws in
            if publicConcept {
                return !story.conditionID_List.isEmpty || story.perspectiveInterpretation_List.contains {
                    !Concept.map[$0.perspectiveID]!.isPrivate
                }
            }
            
            if privateConcept {
                return story.perspectiveInterpretation_List.contains {
                    Concept.map[$0.perspectiveID]!.isPrivate
                }
            }
            
            return true
        }.map(\.placeID)
    }
    
    func queryPlace(_id: String) -> Place {
        object(ofType: Place.self, forPrimaryKey: _id)!
    }
    
    func queryPlaces(_ids: [String]) -> Results<Place> {
        objects(Place.self).filter("_id in %@", _ids)
    }
    
    //TODO
    func queryOrCreatePlace(_ uniquePlace: UniquePlace) -> Place {
//        if let place = realm.object(ofType: Place.self, forPrimaryKey: uniquePlace.title) {
//            return place
        //        } else {
        let newPlace = Place(title: uniquePlace.title, latitude: uniquePlace.latitude, longitude: uniquePlace.longitude)
        try! write {
            add(newPlace, update: .modified)
        }
        return newPlace
//        }
    }
    
    func collectPlace(placeID: String) -> PlaceStory {
        let ind = queryCurrentIndividual()!
        if let placeStory = queryPlaceStory(placeID: placeID) {
            return placeStory
        }
        
        let placeStory = PlaceStory(placeID: placeID)
        try! write {
            ind.placeStory_List.append(placeStory)
        }
        return placeStory
    }
}

// MARK: PlaceStory
extension Realm {
    func queryPlaceStory(placeID: String) -> PlaceStory? {
        queryIndividual(configuration.syncConfiguration!.partitionValue!.stringValue!)!.placeStory_List.first {
            $0.placeID == placeID
        }
    }
    
    func addCondition(_ conditionID: String, toPlace placeID: String) -> Bool {
        let ind = queryCurrentIndividual()!
        let placeStory = ind.placeStory_List.first {
            $0.placeID == placeID
        }!
        guard !placeStory.conditionID_List.contains(conditionID) else {
            return false
        }
        
        
        placeStory.conditionID_List.append(conditionID)
        return true
    }
    
    func removeCondition(_ conditionID: String, fromPlace placeID: String) -> Bool {
        let ind = queryCurrentIndividual()!
        let placeStory = ind.placeStory_List.first {
            $0.placeID == placeID
        }!
        
        guard let index = placeStory.conditionID_List.index(of: conditionID) else {
            return false
        }
        
        placeStory.conditionID_List.remove(at: index)
        return true
    }
    
    func queryConditionIDs(forPlace placeID: String) -> [String] {
        guard let placeStory = queryPlaceStory(placeID: placeID) else {
            fatalError()
        }
        
        return try! placeStory.conditionID_List.map { (id) throws -> String in
            id
        }
    }
    
    func addPerspective(_ perspectiveID: String, fileData: Data, toPlace placeID: String) -> Bool {
        let ind = queryCurrentIndividual()!
        let placeStory = ind.placeStory_List.first {
            $0.placeID == placeID
        }!
        guard !placeStory.perspectiveInterpretation_List.contains(where: { (item) -> Bool in
            item.perspectiveID == perspectiveID
        }) else {
            return false
        }

        placeStory.perspectiveInterpretation_List.append(PerspectiveInterpretation(perspectiveID: perspectiveID, fileData: fileData))
        return true
    }
    
    func replacePerspectiveFileData(_ perspectiveID: String, fileData: Data, toPlace placeID: String) {
        let ind = queryCurrentIndividual()!
        let placeStory = ind.placeStory_List.first {
            $0.placeID == placeID
        }!

        let perspectiveInterpretation = try! placeStory.perspectiveInterpretation_List.first { (item) throws -> Bool in
            item.perspectiveID == perspectiveID
        }!
        try! write {
            perspectiveInterpretation.fileData = fileData
        }
    }
    
    func removePerspective(_ perspectiveID: String, fromPlace placeID: String) -> Bool {
        let ind = queryCurrentIndividual()!
        let placeStory = ind.placeStory_List.first {
            $0.placeID == placeID
        }!

        guard let index = placeStory.perspectiveInterpretation_List.firstIndex(where: { (item) -> Bool in
            item.perspectiveID == perspectiveID
        }) else {
            return false
        }

        placeStory.perspectiveInterpretation_List.remove(at: index)
        return true
    }
    
    func queryPerspectiveIDs(forPlace placeID: String) -> [String] {
        guard let placeStory = queryPlaceStory(placeID: placeID) else {
            fatalError()
        }
        
        return try! placeStory.perspectiveInterpretation_List.map { (item) throws -> String in
            item.perspectiveID
        }
    }
}

// MARK: ConditionRank
extension Realm {
    func createConditionRank_IfNone(conditionID: String) {
        guard queryConditionRank(conditionID: conditionID) == nil else {
            return
        }
        
        let ind = queryCurrentIndividual()!
        ind.conditionRank_List.append(ConditionRank(conditionID: conditionID))
    }
    
    func addPlace(_ placeID: String, toConditionRank conditionID: String) -> Bool {
        guard let conditionRank = queryConditionRank(conditionID: conditionID) else {
            fatalError()
        }
        
        guard nil == conditionRank.placeScore_List.firstIndex(where: {
            $0.placeID == placeID
        }) else {
            return false
        }
        
        let lowerestScore = conditionRank.placeScore_List.last?.score ?? 0
        
        conditionRank.placeScore_List.append(PlaceScore(placeID: placeID, score: lowerestScore))
        return true
    }
    
    func removePlace(_ placeID: String, fromConditionRank conditionID: String) -> Bool {
        guard let conditionRank = queryConditionRank(conditionID: conditionID) else {
            fatalError()
        }
        
        guard let index = conditionRank.placeScore_List.firstIndex(where: {
            $0.placeID == placeID
        }) else {
            return false
        }
        
        conditionRank.placeScore_List.remove(at: index)
        return true
    }
    
    func queryConditionRank(conditionID: String) -> ConditionRank? {
        let ind = queryCurrentIndividual()!
        return ind.conditionRank_List.first {
            $0.conditionID == conditionID
        }
    }
    
    func loadConditionRank_List() -> List<ConditionRank> {
        let ind = queryCurrentIndividual()!
        return ind.conditionRank_List
    }
    
    func queryPrivateConditions() -> [String] {
        let ind = queryCurrentIndividual()!
        return ind.conditionRank_List.map {
            $0.conditionID
        }
    }
}

// Condition
extension Realm {
    func createCondition_IfNone(id id_: String) {
        try! write {
            add(Condition(id: id_), update: .modified)
        }
    }
}
