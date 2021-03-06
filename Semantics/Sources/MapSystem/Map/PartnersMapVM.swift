import Dispatch
import MapKit
import SemDS
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
    
    override func collectPlace(completion: @escaping (Place, PlaceStory) -> ()) {
        super.collectPlace { place, story  in
            completion(place, story)
            DispatchQueue.main.async {
                self.mapVC.map.deselectAnnotation(nil, animated: true)
            }
        }
    }
    
    private func observePartners_List() {
        batchObservePartners([RealmSpace.userID!])
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
                    realm.queryIndividual().placeStory_List.observe(on: RealmSpace.userInitiated.queue) { [weak self] in
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
                print("editAnnotations: \(anno.placeID!) -> \(anno.partnerIDs.count)")
                self.mapVC.map.reload(anno)
            }
        }
    }
}

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
