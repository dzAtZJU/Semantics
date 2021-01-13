extension MultiRealmsAccess {
    static func makeFriends(with friendID: String, completion: @escaping (Profile) -> ()) {
        RealmSpace.userInitiated.realm(friendID) { realm in
            let selfRealm = RealmSpace.userInitiated.privatRealm
            let selfInd = selfRealm.queryIndividual()
            let selfID = selfInd._id
            
            print("[Test] friends: \(friendID) \(selfID)")
            let partnerRealm = realm.queryIndividual()
            let partnerList = partnerRealm.partner_List
            if !partnerList.contains(selfID) {
                try! realm.write {
                    partnerList.append(selfID)
                }
            }
            
            if !selfInd.partner_List.contains(friendID) {
                try! selfRealm.write {
                    selfInd.partner_List.append(friendID)
                }
            }
            
            completion(partnerRealm.profile)
        }
    }
}
