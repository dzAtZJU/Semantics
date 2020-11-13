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
    var panelContentVMDelegate: PanelContentVMDelegate!
    
    var thePlaceId: String?
    
    let allowsCondition: Bool
    
    private var placeStoryToken: NSKeyValueObservation?
    
    private var conditionsToken: NotificationToken?
    private var conditions: [String]? {
        didSet {
            DispatchQueue.main.async {
                self.generateTags()
                self.generateTagChoiceSections()
            }
        }
    }
    
    private var conceptsToken: NotificationToken!
    private var concepts: [String]! {
        didSet {
            DispatchQueue.main.async {
                self.generateTags()
                self.generateTagChoiceSections()
            }
        }
    }
    
    @Published private(set) var tagChoice_Sections: [TagChoiceSection] = []
    
    @Published private(set) var tags: [String] = []
    
    static func new(placeID: String?, allowsCondition: Bool, completion: @escaping (PlaceVM) -> Void) {
        if let placeId = placeID {
            RealmSpace.shared.async {
                let placeStory = SemWorldDataLayer(realm: RealmSpace.shared.realm(RealmSpace.queryCurrentUserID()!)).queryPlaceStory(placeID: placeId)
                let vm = PlaceVM(placeStory: placeStory!, allowsCondition: allowsCondition)
                completion(vm)
            }
        } else {
            // This place hasn't been visited by anyone, thus its not in realm
            completion(PlaceVM(allowsCondition: allowsCondition))
        }
    }
    
    private init(allowsCondition: Bool) {
        self.allowsCondition = allowsCondition
    }
    
    private init(placeStory: PlaceStory, allowsCondition: Bool) {
        self.allowsCondition = allowsCondition
        thePlaceId = placeStory.placeID
                
        conceptsToken = placeStory.perspectiveInterpretation_List.observe {
            switch $0 {
            case .initial(let perspectiveInterpretation_List):
                fallthrough
            case .update(let perspectiveInterpretation_List, _, _, _):
                self.concepts = try! perspectiveInterpretation_List.map({ (item) throws -> String in
                    item.perspectiveID
                }).filter {
                    allowsCondition != Concept.map[$0]!.isPrivate
                }
            case .error(let error):
                fatalError("\(error)")
            }
        }
        
        if allowsCondition {
            conditionsToken = placeStory.conditionID_List.observe {
                switch $0 {
                case .initial(let tags_):
                    fallthrough
                case .update(let tags_, _, _, _):
                    self.conditions = tags_.map { $0 }
                case .error(let error):
                    fatalError("\(error)")
                }
            }
        }
    }
    
    private func generateTags() {
        var tmp = [String]()
        if let conditions = conditions {
            tmp.append(contentsOf: conditions)
        }
        if let concepts = concepts {
            tmp.append(contentsOf: concepts)
        }
        tags = tmp
    }
    
    private func generateTagChoiceSections() {
        var tmp: [TagChoiceSection] = []
        if let placeConditions = conditions {
            let allConditions: [String] =  SemWorldDataLayer(realm: RealmSpace.main.realm(RealmSpace.queryCurrentUserID()!)).queryPrivateConditions()
            let conditionChoices = allConditions.map {
                TagChoice(tag: $0, isChosen: placeConditions.contains($0))
            }
            tmp.append(TagChoiceSection(allowsEditing: true, items: conditionChoices))
        }

        let allConcepts = allowsCondition ? Concept.allPublicTitles: Concept.allPrivateTitles
        let conceptChoices = allConcepts.map {
            TagChoice(tag: $0, isChosen: concepts.contains($0))
        }
        tmp.append(TagChoiceSection(allowsEditing: false, items: conceptChoices))

        tagChoice_Sections = tmp
    }
        
    deinit {
        placeStoryToken?.invalidate()
        conceptsToken?.invalidate()
        conditionsToken?.invalidate()
    }
}

extension PlaceVM: TagsVCDelegate {
    func tagsVCDidFinishChoose(_ tagsVC: TagsVC, tagChoice_Sections: [TagChoiceSection]) {
        let publicLayer = SemWorldDataLayer(realm: RealmSpace.main.realm(RealmSpace.partitionValue))
        let privateLayer = SemWorldDataLayer2(layer1: SemWorldDataLayer(realm: RealmSpace.main.realm(RealmSpace.queryCurrentUserID()!)))
        tagChoice_Sections.forEach {
            if $0.allowsEditing {
                $0.items.forEach {
                    if $0.isChosen {
                        publicLayer.createCondition_IfNone(id: $0.tag)
                        privateLayer.projectCondition($0.tag, on: thePlaceId!)
                    } else {
                        privateLayer.withdrawCondition($0.tag, from: thePlaceId!)
                    }
                }
            } else {
                $0.items.forEach {
                    if $0.isChosen {
                        switch $0.tag {
                        case Concept.Seasons.title:
                            let fileData = try! JSONEncoder().encode(SeasonsInterpretation())
                            privateLayer.projectPerspective($0.tag, fileData: fileData, on: thePlaceId!)
                        case Concept.Scent.title:
                            let fileData = try! JSONEncoder().encode(ScentInterpretation())
                            privateLayer.projectPerspective($0.tag, fileData: fileData, on: thePlaceId!)
                        default:
                            fatalError()
                        }
                    } else {
                        privateLayer.withdrawPerspective($0.tag, from: thePlaceId!)
                    }
                }
            }
        }
    }
}
