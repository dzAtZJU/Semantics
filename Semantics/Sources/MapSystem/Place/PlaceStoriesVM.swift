import Foundation
import RealmSwift

class PlaceStoriesVM {
    static let queue = DispatchQueue.main//DispatchQueue(label: "queue-PlaceStoriesVM", qos: .userInitiated, target: DispatchQueue.global(qos: .userInitiated))
    
    static let realmSpace = RealmSpace(queue: queue)
    
    static func new(placeID: String, partnersID: [String], completion: @escaping (PlaceStoriesVM)->()) {
        var result: [PlaceStory] = []
        partnersID.forEach { id in
            let realm = realmSpace.realm(id)
            let placeStory = realm.queryPlaceStory(placeID: placeID)!
            if id == RealmSpace.userID {
                result.insert(placeStory, at: 0)
            } else {
                result.append(placeStory)
            }
        }
        completion(PlaceStoriesVM(placeStories: result))
    }
    
    let placeStories: [PlaceStory]
    
    init(placeStories: [PlaceStory]) {
        self.placeStories = placeStories
    }
    
    var count: Int {
        placeStories.count
    }
    
    var firstPlaceStoryVM: PlaceStoryVM {
        createVM(index: 0)
    }
    
    func placeStoryVM(after vm: PlaceStoryVM) -> PlaceStoryVM? {
        let newIndex = vm.pageIndex + 1
        guard newIndex != count else {
            return nil
        }
        
        return createVM(index: newIndex)
    }
    
    func placeStoryVM(before vm: PlaceStoryVM) -> PlaceStoryVM? {
        let newIndex = vm.pageIndex - 1
        guard newIndex != -1 else {
            return nil
        }
        
        return createVM(index: newIndex)
    }
    
    private func createVM(index: Int) -> PlaceStoryVM {
        let tmp = PlaceStoryVM(allowsCondition: false, placeStory: placeStories[index])
        tmp.pageIndex = index
        let owner = placeStories[index].owner.first!
        tmp.partnerProfile = owner.profile
        return tmp
    }
    
    func indexForPlaceStoryVM(_ vm: PlaceStoryVM) -> Int {
        vm.pageIndex
    }
}

extension Individual {
    var profile: Profile {
        Profile(name: title ?? _id, image: avatar == nil ? nil : UIImage(data: avatar!))
    }
}
