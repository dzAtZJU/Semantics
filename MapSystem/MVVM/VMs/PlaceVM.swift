import Foundation
import Combine
import RealmSwift

struct PlaceInteraction {
    static let ordinary = PlaceInteraction(individualAble: "Compare", humankindAble: "Search", anchor: "Condition", anchorCollectionTitle: "Conditions")
    static let unique = PlaceInteraction(individualAble: "Describe", humankindAble: "Talks", anchor: "Perspective", anchorCollectionTitle: "Dictionary")
    
    let individualAble: String
    let humankindAble: String
    let anchor: String
    let anchorCollectionTitle: String
}

class PlaceVM: PanelContentVM {
    var thePlaceId: String?
    
    var panelContentVMDelegate: PanelContentVMDelegate!
    
    @Published private(set) var tags: [String]?
    
    @Published private(set) var placeState: PlaceState
    
    private var placeStoryToken: NSKeyValueObservation?
    
    private var tagsToken: NotificationToken?
    
    private(set) var uniqueness: Uniqueness?
    
    static func new(placeID: String?, uniqueness: Uniqueness?, completion: @escaping (PlaceVM) -> Void) {
        if let placeId = placeID {
            RealmSpace.shared.async {
                let placeStory = SemWorldDataLayer(realm: RealmSpace.shared.realm(RealmSpace.queryCurrentUserID()!)).queryPlaceStory(placeID: placeId)
                let vm = PlaceVM(placeStory: placeStory!, uniqueness: uniqueness!)
                completion(vm)
            }
        } else {
            // This place hasn't been visited by anyone, thus its not in realm
            completion(PlaceVM())
        }
    }
    
    private init(placeStory placeStory_: PlaceStory, uniqueness uniqueness_: Uniqueness) {
        thePlaceId = placeStory_.placeID
        uniqueness = uniqueness_
        placeState = PlaceState(rawValue: placeStory_.state)!
        
        let tag_List: List<String> = {
            switch uniqueness! {
            case .ordinary:
                return placeStory_.conditionID_List
            case .unique:
                return placeStory_.perspectiveID_List
            }
        }()
        tagsToken = tag_List.observe {
            switch $0 {
            case .initial(let tags_):
                fallthrough
            case .update(let tags_, _, _, _):
                self.tags = tags_.map { $0 }
            case .error(let error):
                fatalError("\(error)")
            }
        }
        
        placeStoryToken = placeStory_.observe(\.state, options: [.new], changeHandler: { (placeStory, change) in
            self.placeState = PlaceState(rawValue: change.newValue!)!
        })
    }
    
    private init() {
        placeState = .neverBeen
    }
    
    var interactionTitles: PlaceInteraction? {
        switch uniqueness! {
        case .ordinary:
            return PlaceInteraction.ordinary
        case .unique:
            return PlaceInteraction.unique
        }
    }
        
    var tagChoice_List: [TagChoice] {
        var tagChoice_List: [TagChoice] = []
        if let tags = tags {
            let privateTags: [String] = {
                switch uniqueness! {
                case .ordinary:
                    return SemWorldDataLayer(realm: RealmSpace.main.realm(RealmSpace.queryCurrentUserID()!)).queryPrivateConditions()
                case .unique:
                    return Perspective.all
                }
            }()
            
            tagChoice_List = privateTags.map {
                TagChoice(tag: $0, isChosen: tags.contains($0))
            }
        }
        return tagChoice_List
    }
    
    var enableAddingTag: Bool {
        uniqueness! == .ordinary
    }
    
    deinit {
        placeStoryToken?.invalidate()
        tagsToken?.invalidate()
    }
}

extension PlaceVM: TagsVCDelegate {
    func tagsVCDidFinishChoose(_ tagsVC: TagsVC, tagChoice_List: [TagChoice]) {
        guard let tags = tags else {
            fatalError()
        }
        
        let publicLayer = SemWorldDataLayer(realm: RealmSpace.main.realm(RealmSpace.partitionValue))
        let privateLayer = SemWorldDataLayer2(layer1: SemWorldDataLayer(realm: RealmSpace.main.realm(RealmSpace.queryCurrentUserID()!)))
        tagChoice_List.forEach {
            if $0.isChosen && !tags.contains($0.tag) {
                switch uniqueness! {
                case .ordinary:
                    publicLayer.createCondition_IfNone(id: $0.tag)
                    privateLayer.projectCondition($0.tag, on: thePlaceId!)
                case .unique:
                    privateLayer.projectPerspective($0.tag, on: thePlaceId!)
                }
            } else if !$0.isChosen && tags.contains($0.tag) {
                switch uniqueness! {
                case .ordinary:
                    privateLayer.withdrawCondition($0.tag, from: thePlaceId!)
                case .unique:
                    privateLayer.withdrawPerspective($0.tag, from: thePlaceId!)
                }
            }
        }
    }
}
