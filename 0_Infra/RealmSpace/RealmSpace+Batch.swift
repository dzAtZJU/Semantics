import Foundation
struct UserIDAndPlaceIDs {
    let userID: String
    let placeIDs: [String]
    
    static func placeID2userIDs(from: [UserIDAndPlaceIDs]) -> [String: [String]] {
        var result: [String: [String]] = [:]
        from.forEach {
            let userID = $0.userID
            $0.placeIDs.forEach { placeID in
                result[placeID, default: []].append(userID)
            }
        }
        return result
    }
}

extension RealmSpace {
    static func batchLoadUserPlaceIDs(userIDs: [String], completion: @escaping ([UserIDAndPlaceIDs]) -> ()) {
        let group = DispatchGroup()
        var result: [UserIDAndPlaceIDs] = []
        let serializer = DispatchQueue(label: "protect-[UserIDAndPlaceIDs]", qos: .userInitiated)
        userIDs.forEach { id in
            group.enter()
            let st = Date().timeIntervalSince1970
            RealmSpace.create().realm(id) { realm in
                let et1 = Date().timeIntervalSince1970
                print("[Measure] open realm: \(et1-st)")
                let placeIDs = realm.loadUserPlaceIDsRequire(publicConcept: false, privateConcept: true, userID: id)
                serializer.async {
                    result.append(UserIDAndPlaceIDs(userID: id, placeIDs: placeIDs))
                    group.leave()
                }
            }
        }
        group.notify(queue: .global(qos: .userInitiated)) {
            completion(result)
        }
    }
    
    static func batchLoadPlaceID2UserIDs(fromUserIDs userIDs: [String], completion: @escaping ([String:[String]]) -> ()) {
        RealmSpace.batchLoadUserPlaceIDs(userIDs: userIDs) {
            let placeID2UserIDs = UserIDAndPlaceIDs.placeID2userIDs(from: $0)
            completion(placeID2UserIDs)
        }
    }
}
