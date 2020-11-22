import Combine
import Foundation

protocol FillingSection {
    var sections: [ConceptSection] {
        get
    }
    
    mutating func addItem(_ item: ConceptItem)
}

extension ScentInterpretation: FillingSection {
    var sections: [ConceptSection] {
        var tmp = [ConceptSection]()
        let instanceSection = ConceptSectionInfo(headerType: .TitleWithAdding(ConceptLink.Instance.title), addingItemType: .AddingLabel)
        let instanceItems = instance.map {
            ConceptItem(itemType: .Label($0))
        }
        tmp.append(ConceptSection(sectionInfo: instanceSection, items: instanceItems))
        
        return tmp
    }
    
    mutating func addItem(_ item: ConceptItem) {
        guard case let .Label(text) = item.itemType else {
            fatalError()
        }
        
        instance.insert(text, at: 0)
    }
}

extension TrustInterpretation: FillingSection {
    var sections: [ConceptSection] {
        var tmp = [ConceptSection]()
        let caBeTrustedSection = ConceptSectionInfo(headerType: .TitleWithAdding(ConceptLink.CanBeTrusted.title), addingItemType:  .AddingOpinion)
        let caBeTrustedItems = caBeTrusted.map { (opinion) -> ConceptItem in
            ConceptItem(itemType: .Opinion(opinion))
        }
        tmp.append(ConceptSection(sectionInfo: caBeTrustedSection, items: caBeTrustedItems))
        
        return tmp
    }
    
    mutating func addItem(_ item: ConceptItem) {
        guard case let .Opinion(opinion) = item.itemType else {
            fatalError()
        }
        
        caBeTrusted.insert(opinion, at: 0)
    }
}

class ConceptVM: AConceptVM {
    let placeID: String
    
    let interpretationInRealm: PerspectiveInterpretation
    
    var fileDataToken: NSKeyValueObservation?
    
    let concept: Concept
    
    private var interpretation: (Interpretation & FillingSection)!
    
    @Published var sections: [ConceptSection]!
    
    var sectionsPublisher: Published<[ConceptSection]?>.Publisher {
        $sections
    }
    
    init(concept: Concept, placeID: String) {
        self.placeID = placeID
        self.concept = concept
                
        let privateLayer = SemWorldDataLayer(realm: RealmSpace.main.realm(RealmSpace.queryCurrentUserID()!))
        interpretationInRealm = try! privateLayer.queryPlaceStory(placeID: placeID)!.perspectiveInterpretation_List.first { (item) throws-> Bool in
            item.perspectiveID == concept.title
        }!
        fileDataToken = interpretationInRealm.observe(\.fileData, options: .new) { (_, change) in
            self.generateInterpretation(fromRealm: change.newValue!!)
        }
        
        generateInterpretation(fromRealm: interpretationInRealm.fileData!)
    }
    
    private func generateInterpretation(fromRealm data: Data) {
        interpretation = {
            switch concept.title {
            case Concept.Scent.title:
                return try! JSONDecoder().decode(ScentInterpretation.self, from: data)
            case Concept.Trust.title:
                return try! JSONDecoder().decode(TrustInterpretation.self, from: data)
            default:
            fatalError()
            }
        }()
        
        sections = interpretation.sections
    }
    
    func addItem(_ item: ConceptItem) {
        var newInterpretation = interpretation!
        newInterpretation.addItem(item)
        let data: Data = {
            switch concept.title {
            case Concept.Scent.title:
                return try! JSONEncoder().encode(newInterpretation as! ScentInterpretation)
            case Concept.Trust.title:
                return try! JSONEncoder().encode(newInterpretation as! TrustInterpretation)
            default:
            fatalError()
            }
        }()
        SemWorldDataLayer(realm: RealmSpace.main.realm(RealmSpace.queryCurrentUserID()!)).replacePerspectiveFileData(concept.title, fileData: data, toPlace: placeID)
    }
}

class MockConceptVM: AConceptVM {
    var concept: Concept = .Trust
    
    @Published var sections: [ConceptSection]!
    
    var sectionsPublisher: Published<[ConceptSection]?>.Publisher {
        $sections
    }
    
    init() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.sections = [
                ConceptSection(
                    sectionInfo: .init(headerType: .TitleWithAdding(ConceptLink.CanBeTrusted.title),
                                       addingItemType: .AddingOpinion),
                    items: [
                        .init(itemType: .Opinion(.init(title: "Most other people", format: .Poll, data: try! JSONEncoder().encode(Opinion.Poll(agreePortion: 30, url: URL(string: "https://www.youtube.com/watch?v=iAZwvTV3CyQ")!))))),
                        .init(itemType: .Opinion(.init(title: "School", format: .Personal, data: try! JSONEncoder().encode(Opinion.Individual(isAgree: false)))))]
                )
            ]
        }
    }
    
    func addItem(_ item: ConceptItem) {
        fatalError()
    }
}
