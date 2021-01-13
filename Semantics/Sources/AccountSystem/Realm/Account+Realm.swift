import RealmSwift

extension Realm {
    func tryCreateIndividual(userName: String) -> Individual {
        let userID = partitionValue!
        var individual = object(ofType: Individual.self, forPrimaryKey: userID)
        if individual == nil {
            individual = Individual(id: userID, title: userName)
            try! write {
                add(individual!)
            }
        }
        
        return individual!
    }
    
    func queryIndividual() -> Individual {
        let individual = object(ofType: Individual.self, forPrimaryKey: partitionValue!)!
        return individual
    }
        
    func modifyName(_ name: String?) {
        let ind = queryIndividual()
        try! write {
            ind.title = name
        }
    }

    func modifyAvatar(_ avatar: Data?) {
        let ind = queryIndividual()
        try! write {
            ind.avatar = avatar
        }
    }
}
