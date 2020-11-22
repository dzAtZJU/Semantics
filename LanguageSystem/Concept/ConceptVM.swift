import Combine
import Foundation

protocol FillingSection {
    var sections: [ConceptSection] {
        get
    }
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
}

class ConceptVM {
    let placeID: String
    
    let interpretationInRealm: PerspectiveInterpretation
    
    var fileDataToken: NSKeyValueObservation?
    
    let concept: Concept
    
    @Published var sections: [ConceptSection]!
    
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
        let interpretation: Interpretation & FillingSection = {
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
    
    func addInstance(_ instance: String, item: ConceptItem) {
//        var newConceptInterpretation = individualInterpretation!
//        newConceptInterpretation.instance.insert(instance, at: 0)
//        SemWorldDataLayer(realm: RealmSpace.main.realm(RealmSpace.queryCurrentUserID()!)).replacePerspectiveFileData(Concept.Scent.title, fileData: try! JSONEncoder().encode(newConceptInterpretation), toPlace: placeID)
    }
}


