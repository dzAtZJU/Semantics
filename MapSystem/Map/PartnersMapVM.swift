import Dispatch
import MapKit
import RealmSwift

class PartnersMapVM: AMapVM {
    private var partnersToken: NotificationToken?
    
    private var partnerPlaceStoryListTokens: [NotificationToken] = []
    
    private var loadCompletion: (() -> ())?
    
    init() {
        super.init(circleOfTrust: .private)
    }
    
    override func load(completion: @escaping () -> ()) {
        loadCompletion = completion
        observePartners_List()
    }
    
    private func observePartners_List() {
        RealmSpace.userInitiated.async { [weak self] in
            self?.partnersToken = RealmSpace.userInitiated.privatRealm.queryPartners().observe(on: RealmSpace.userInitiated.queue) { [weak self] in
                guard let self = self else {
                    return
                }
                
                switch $0 {
                case .initial(let partners):
                    self.batchObservePartners(partners.array)
                case .update(let partners, _,let insertions, _):
                    self.batchObservePartners(partners.array[insertions])
                case .error(let error):
                    fatalError("\(error)")
                }
            }
        }
    }
    
    private func batchObservePartners(_ users: [String]) {
        users.forEach { userID in
            RealmSpace.userInitiated.realm(userID) {  [weak self] realm in
                guard let self = self else {
                    return
                }
                self.partnerPlaceStoryListTokens.append(
                    realm.queryIndividual(userID)!.placeStory_List.observe(on: RealmSpace.userInitiated.queue) { [weak self] in
                        guard let self = self else {
                            return
                        }
                        
                        switch $0 {
                        case .initial(let placeStory_List):
                            let newPlaceIDs = try! placeStory_List.map { (item) throws -> String in
                                item.placeID
                            }
                            self.loadUserIDPlaceIDs(UserIDAndPlaceIDs(userID: userID, placeIDs: newPlaceIDs))
                            self.loadCompletion?()
                            self.loadCompletion = nil
                        case .update(let placeStory_List, _,let insertions, _):
                            let newPlaceIDs = placeStory_List.array[insertions].map {
                                $0.placeID
                            }
                            self.loadUserIDPlaceIDs(UserIDAndPlaceIDs(userID: userID, placeIDs: newPlaceIDs))
                        case .error(let error):
                            fatalError("\(error)")
                        }
                    }
                )
            }
        }
    }
    
    private func loadUserIDPlaceIDs(_ userIDAndPlaceIDs: UserIDAndPlaceIDs) {
        let placeID2userIDs = UserIDAndPlaceIDs.placeID2userIDs(from: [userIDAndPlaceIDs])
        processAnnotations(placeID2UserIDs: placeID2userIDs)
    }
    
    private func processAnnotations(placeID2UserIDs: [String : [String]]) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            
            let predicate: (String) -> Bool = { key in
                self.mapVC.partnersAnnotations.contains {
                    $0.placeID == key
                }
            }
            let newItems = placeID2UserIDs.filter { (key, _) -> Bool in
                !predicate(key)
            }
            let changedItems = placeID2UserIDs.filter { (key, _) -> Bool in
                predicate(key)
            }
            
            self.loadNewAnnotations(placeID2UserIDs: newItems)
            self.editAnnotations(placeID2UserIDs: changedItems)
        }
    }
    
    private func loadNewAnnotations(placeID2UserIDs: [String : [String]]) {
        let places = RealmSpace.main.publicRealm.queryPlaces(_ids: Array(placeID2UserIDs.keys))
        let newAnnos = try! places.map { (place) throws -> PartnersAnnotation in
            let freezed = place.freeze()
            let partnersID = placeID2UserIDs[freezed._id]!
            return PartnersAnnotation(place: freezed, partnerIDs: partnersID)
        }
        mapVC.map.addAnnotations(newAnnos)
    }
    
    private func editAnnotations(placeID2UserIDs: [String : [String]]) {
        self.mapVC.partnersAnnotations.forEach { anno in
            if let newUsers = placeID2UserIDs[anno.placeID!] {
                anno.partnerIDs.append(contentsOf: newUsers)
            }
        }
    }
    
    override func collectPlace(completion: @escaping (Place, PlaceStory) -> ()) {
        super.collectPlace { (place, placeStory) in
            completion(place, placeStory)
            DispatchQueue.main.async {
                self.mapVC.map.removeAnnotations(self.mapVC.map.annotations)
                self.load {}
            }
        }
    }
    
//    private func loadPartners(_ users: [String], completion: (() -> ())? = nil) {
//        RealmSpace.batchLoadPlaceID2UserIDs(fromUserIDs: users) { [weak self] placeID2UserIDs in
//            guard let self = self else {
//                return
//            }
//
//            let predicate: (String) -> Bool = { key in
//                self.mapVC.partnersAnnotations.contains {
//                    $0.placeID == key
//                }
//            }
//
//            let newItems = placeID2UserIDs.filter { (key, _) -> Bool in
//                !predicate(key)
//            }
//            self.loadNewAnnotations(placeID2UserIDs: newItems)
//
//            let changedItems = placeID2UserIDs.filter { (key, _) -> Bool in
//                predicate(key)
//            }
//            self.editAnnotations(placeID2UserIDs: changedItems)
//
//            DispatchQueue.main.async {
//                completion?()
//            }
//        }
//    }
}
