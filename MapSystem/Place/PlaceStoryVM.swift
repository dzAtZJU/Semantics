import Foundation
import Combine
import RealmSwift

class PlaceStoryVM: APlaceStoryVM {
    static func new(placeID: String?, allowsCondition: Bool, completion: @escaping (PlaceStoryVM) -> Void) {
        guard let placeID = placeID else {
            completion(PlaceStoryVM(allowsCondition: allowsCondition))
            return
        }
        
        RealmSpace.userInitiated.async {
            let placeStory = RealmSpace.userInitiated.privatRealm.queryPlaceStory(placeID: placeID)!
            
            let vm = PlaceStoryVM(allowsCondition: allowsCondition, placeStory: placeStory)
            completion(vm)
        }
    }
    
    var parent: MapVM?
        
    var thePlaceId: String?
    
    var partnerProfile: Profile!
    
    @Published private(set) var tags: [String]!
    
    var tagsPublisher: Published<[String]?>.Publisher {
        $tags
    }
    
    var tagChoice_Sections: [TagChoiceSection] {
        var tmp: [TagChoiceSection] = []
        if allowsCondition {
            var section = TagChoiceSection(allowsEditing: true, items: [])
            let allConditions: [String] = RealmSpace.main.privatRealm.queryPrivateConditions()
            let placeConditions = conditions ?? []
            let conditionChoices = allConditions.map {
                TagChoice(tag: $0, isChosen: placeConditions.contains($0))
            }
            section.items.append(contentsOf: conditionChoices)
            tmp.append(section)
        }

        let allConcepts = allowsCondition ? Concept.allPublicTitles: Concept.allPrivateTitles
        let placeConcepts = concepts ?? []
        let conceptChoices = allConcepts.map {
            TagChoice(tag: $0, isChosen: placeConcepts.contains($0))
        }
        tmp.append(TagChoiceSection(allowsEditing: false, items: conceptChoices))

        return tmp
    }

    private let allowsCondition: Bool
    
    private var conditionsToken: NotificationToken?
    private var conditions: [String]? {
        didSet {
            DispatchQueue.main.async {
                self.generateTags()
            }
        }
    }
    
    private var conceptsToken: NotificationToken?
    private var concepts: [String]! {
        didSet {
            DispatchQueue.main.async {
                self.generateTags()
            }
        }
    }
    
    private init(allowsCondition: Bool) {
        self.allowsCondition = allowsCondition
    }
    
    private convenience init(allowsCondition: Bool, placeStory: PlaceStory) {
        self.init(allowsCondition: allowsCondition)
        
        loadPlace(placeStory: placeStory)
    }
    
    private func loadPlace(placeStory: PlaceStory) {
        thePlaceId = placeStory.placeID
        
        conceptsToken = placeStory.perspectiveInterpretation_List.observe {
            switch $0 {
            case .initial(let perspectiveInterpretation_List):
                fallthrough
            case .update(let perspectiveInterpretation_List, _, _, _):
                self.concepts = try! perspectiveInterpretation_List.map({ (item) throws -> String in
                    item.perspectiveID
                }).filter {
                    self.allowsCondition != Concept.map[$0]!.isPrivate
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
        
    deinit {
        conceptsToken?.invalidate()
        conditionsToken?.invalidate()
    }
}

extension PlaceStoryVM: TagsVCDelegate {
    func tagsVCDidFinishChoose(_ tagsVC: TagsVC, tagChoice_Sections: [TagChoiceSection]) {
        let action: () -> () = {
            RealmSpace.userInitiated.async {
                let publicLayer = RealmSpace.userInitiated.publicRealm
                let privateLayer = RealmSpace.userInitiated.privatRealm
                tagChoice_Sections.forEach {
                    if $0.allowsEditing {
                        $0.items.forEach {
                            if $0.isChosen {
                                publicLayer.createCondition_IfNone(id: $0.tag)
                                privateLayer.projectCondition($0.tag, on: self.thePlaceId!)
                            } else {
                                privateLayer.withdrawCondition($0.tag, from: self.thePlaceId!)
                            }
                        }
                    } else {
                        $0.items.forEach {
                            if $0.isChosen {
                                let tag = $0.tag
                                let fileData: Data = {
                                    switch tag {
                                    case Concept.Seasons.title:
                                        return try! JSONEncoder().encode(SeasonsInterpretation())
                                    case Concept.Scent.title:
                                        return try! JSONEncoder().encode(ScentInterpretation())
                                    case Concept.Trust.title:
                                        return try! JSONEncoder().encode(TrustInterpretation())
                                    default:
                                        fatalError()
                                    }
                                }()
                                privateLayer.projectPerspective($0.tag, fileData: fileData, on: self.thePlaceId!)
                            } else {
                                privateLayer.withdrawPerspective($0.tag, from: self.thePlaceId!)
                            }
                        }
                    }
                }
            }
        }
        
        guard thePlaceId != nil else {
            parent?.collectPlace {
                self.loadPlace(placeStory: $0)
                action()
            }
            
            return
        }
        
        action()
    }
}

class MockPlaceStoryVM: APlaceStoryVM {
    static let mock1: MockPlaceStoryVM = {
        let tmp = MockPlaceStoryVM()
        tmp.partnerProfile = Profile(name: "Mila", image: UIImage(named: "mila")!)
        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            tmp.tags = ["A1", "B1", "C1"]
        }
        return tmp
    }()
    
    static let mock2: MockPlaceStoryVM = {
        let tmp = MockPlaceStoryVM()
        tmp.partnerProfile = Profile(name: "Eileen", image: UIImage(named: "eileen")!)
        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            tmp.tags = ["A2", "B2"]
        }
        return tmp
    }()
    
    @Published private(set) var tags: [String]!
    
    var tagsPublisher: Published<[String]?>.Publisher {
        $tags
    }
    
    var tagChoice_Sections: [TagChoiceSection] = []
    
    var partnerProfile: Profile!
    
    func tagsVCDidFinishChoose(_ tagsVC: TagsVC, tagChoice_Sections: [TagChoiceSection]) {
        
    }
}
