import Dispatch
import MapKit

private struct UserIDAndPlaceIDs {
    let userID: String
    let placeIDs: [String]
}

class PartnersMapVM: AMapVM {
    init() {
        super.init(circleOfTrust: .private)
    }
    
    override func collectPlace(completion: @escaping (Place, PlaceStory) -> ()) {
        super.collectPlace { (place, placeStory) in
            completion(place, placeStory)
            DispatchQueue.main.async {
                self.mapVC.map.removeAnnotations(self.mapVC.map.annotations)
                self.loadPlaces {}
            }
        }
    }
    
    override func loadPlaces(completion: @escaping () -> ()) {
        RealmSpace.userInitiated.async {
            let partners = try! RealmSpace.userInitiated.privatRealm.queryPartners().map({ (id) throws -> String in
                id
            }) + [RealmSpace.userID!]
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
                    let st = Date().timeIntervalSince1970
                    realmSpace.realm(id) { realm in
                        let et1 = Date().timeIntervalSince1970
                        print("[Measure] open realm: \(et1-st)")
                        let placeIDs = realm.loadVisitedPlacesRequire(publicConcept: false, privateConcept: true, userID: id)
                        serializer.async {
                            result.append(UserIDAndPlaceIDs(userID: id, placeIDs: placeIDs))
                            group.leave()
                        }
                    }
                }
                
                group.notify(queue: .global(qos: .userInitiated)) {
                    var placeID2UserIDs: [String: [String]] = [:]
                    result.forEach {
                        let partnerID = $0.userID
                        $0.placeIDs.forEach { placeID in
                            placeID2UserIDs[placeID, default: []].append(partnerID)
                        }
                    }
                    
                    RealmSpace.userInitiated.publicRealm {
                        let places = $0.queryPlaces(_ids: Array(placeID2UserIDs.keys))
                        let newAnnos = try! places.map { (place) throws -> PartnersAnnotation in
                            let freezed = place.freeze()
                            let partnersID = placeID2UserIDs[freezed._id]!
                            return PartnersAnnotation(place: freezed, partnerIDs: partnersID)
                        }
                        
                        DispatchQueue.main.async {
                            self.mapVC.map.addAnnotations(newAnnos)
                            completion()
                        }
                    }
                }
            }
        }
    }
}
