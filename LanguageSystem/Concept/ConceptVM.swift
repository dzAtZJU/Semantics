import Combine
import Foundation

struct ScentInterpretation: Interpretation {
    var instance: [String] = []
}

class ConceptVM {
    let placeID: String
    
    let interpretationInRealm: PerspectiveInterpretation
    
    var fileDataToken: NSKeyValueObservation?
    
    @Published var conceptInterpretation: ScentInterpretation! = nil
    
    let concept: Concept
    
    init(concept: Concept, placeID: String) {
        self.placeID = placeID
        self.concept = concept
                
        let privateLayer = SemWorldDataLayer(realm: RealmSpace.main.realm(RealmSpace.queryCurrentUserID()!))
        interpretationInRealm = try! privateLayer.queryPlaceStory(placeID: placeID)!.perspectiveInterpretation_List.first { (item) throws-> Bool in
            item.perspectiveID == concept.title
        }!
        fileDataToken = interpretationInRealm.observe(\.fileData, options: .new) { (_, change) in
            self.generateConceptInterpretation(fromRealm: change.newValue!!)
        }
        
        generateConceptInterpretation(fromRealm: interpretationInRealm.fileData!)
    }
    
    private func generateConceptInterpretation(fromRealm data: Data) {
        conceptInterpretation = try! JSONDecoder().decode(ScentInterpretation.self, from: data)
    }
    
    func addInstance(_ instance: String, item: TitleItem) {
        var newConceptInterpretation = conceptInterpretation!
        newConceptInterpretation.instance.insert(instance, at: 0)
        SemWorldDataLayer(realm: RealmSpace.main.realm(RealmSpace.queryCurrentUserID()!)).replacePerspectiveFileData(Concept.Scent.title, fileData: try! JSONEncoder().encode(newConceptInterpretation), toPlace: placeID)
    }
}


