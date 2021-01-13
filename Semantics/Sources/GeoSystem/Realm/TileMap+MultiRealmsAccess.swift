import RealmSwift
import Dispatch
import SemRealm
import Combine

extension MultiRealmsAccess {
    static func loadRealms(partitionValues: [String], callbackQueue: DispatchQueue) -> AnyPublisher<Realm, Never> {
        let subject = PassthroughSubject<Realm, Never>()
        let group = DispatchGroup()
        for partitionValue in partitionValues {
            group.enter()
            Realm.asyncOpen(partitionValue: partitionValue, callbackQueue: callbackQueue) { result in
                let realm = try! result.get()
                subject.send(realm)
                group.leave()
            }
        }
        group.notify(queue: callbackQueue) {
            subject.send(completion: .finished)
        }
        return subject.eraseToAnyPublisher()
    }
}


//RealmSpace.userInitiated.realm(userID) {  [weak self] realm in
//    guard let self = self else {
//        return
//    }
//    self.partnerPlaceStoryListTokens.append(
//        realm.queryIndividual(userID)!.placeStory_List.observe(on: RealmSpace.userInitiated.queue) { [weak self] in
//            guard let self = self else {
//                return
//            }
//
//            switch $0 {
//            case .initial(let placeStory_List):
//                let newPlaceIDs = try! placeStory_List.map { (item) throws -> String in
//                    item.placeID
//                }
//                self.loadUserIDPlaceIDs(UserIDAndPlaceIDs(userID: userID, placeIDs: newPlaceIDs))
//                self.loadCompletion?()
//                self.loadCompletion = nil
//            case .update(let placeStory_List, _,let insertions, _):
//                let newPlaceIDs = placeStory_List.array[insertions].map {
//                    $0.placeID
//                }
//                self.loadUserIDPlaceIDs(UserIDAndPlaceIDs(userID: userID, placeIDs: newPlaceIDs))
//            case .error(let error):
//                fatalError("\(error)")
//            }
//        }
//    )
//}
//}
//
