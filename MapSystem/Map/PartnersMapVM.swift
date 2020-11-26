import Dispatch

private struct UserIDAndPlaceIDs {
    let userID: String
    let placeIDs: [String]
}

class PartnersMapVM: AMapVM {
    func loadPlaces() {
        let partners = ["5fbf8462ec84c7fee989efd8", "5fbf84f0a476d2d810fee7a9"]
        DispatchQueue.global(qos: .userInitiated).async {
            let group = DispatchGroup()
            for _ in 0..<partners.count {
                group.enter()
            }
            var result: [UserIDAndPlaceIDs] = []
            let serializer = DispatchQueue(label: "protect-[UserIDAndPlaceIDs]", qos: .userInitiated)
            DispatchQueue.concurrentPerform(iterations: partners.count) { index in
                let id = partners[index]
                let queue = DispatchQueue(label: "queue\(id)-for-realm", qos: .userInitiated, target: DispatchQueue.global(qos: .userInitiated))
                let realmSpace = RealmSpace(queue: queue)
                realmSpace.realm(id) {realm in
                    let placeIDs = realm.loadVisitedPlacesRequire(publicConcept: false, privateConcept: false, userID: id)
                    serializer.async {
                        result.append(UserIDAndPlaceIDs(userID: id, placeIDs: placeIDs))
                        group.leave()
                    }
                }
            }
            
            group.notify(queue: .main) {
                print("PartnersMapVM: \(result)")
            }
        }
    }
}


//RealmSpace.userInitiated.publicRealm { publicRealm in
//    let annos = try! SemWorldDataLayer(realm: publicRealm).queryPlaces(_ids: map { place throws in
//        SemAnnotation(place: place, type: .visited, color: UIColor.random)
//        //Int.random(in: 0..<3) % 3 == 0 ? .brown: .cyan
//    }
//
//    DispatchQueue.main.async {
//        self.appendAnnotations(annos)
//    }
//}
