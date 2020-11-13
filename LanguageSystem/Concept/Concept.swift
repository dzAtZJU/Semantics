struct ConceptLink: Hashable {
    static let Comparison = ConceptLink(title: "Comparison")
    
    static let Illustrates = ConceptLink(title: "Illustrates")
    
    static let Instance = ConceptLink(title: "Instance")
    
    let title: String
}

struct Concept {
    // MARK: Public
    static var Seasons = Concept(title: "Seasons", isPrivate: false)
    
    static var Scenery = Concept(title: "Scenery", isPrivate: false)
    
    static let Period = Concept(title: "Period", isPrivate: false)
    
    // MARK: Resource
    static let Bread = Concept(title: "Bread", isPrivate: false)
    static let Coffee = Concept(title: "Coffee", isPrivate: false)
    static let Fragrance = Concept(title: "Fragrance", isPrivate: false)
    static let Forest = Concept(title: "Forest", isPrivate: false)
    
    // MARK: Private
    static var Scent = Concept(title: "Scent", isPrivate: true)
    
    static func load() {
        Seasons.map[ConceptLink.Comparison] = [.Scenery]
        Seasons.map[ConceptLink.Illustrates] = [.Period]
        
        Scenery.map[ConceptLink.Comparison] = [.Seasons]
        
        Scent.map[ConceptLink.Instance] = [.Bread, .Coffee, .Fragrance, .Forest]
    }
    
    static var allPublic: [Concept] {
        [Seasons]
    }
    
    static var allPublicTitles: [String] {
        allPublic.map(\.title)
    }
    
    static var allPrivate: [Concept] {
        [Scent]
    }
    
    static var allPrivateTitles: [String] {
        allPrivate.map(\.title)
    }
    
    static let map: [String: Concept] = [
        Concept.Seasons.title: Concept.Seasons,
        Concept.Scent.title: Concept.Scent
    ]
    
    let title: String
    let isPrivate: Bool
    var map: [ConceptLink: [Concept]] = [:]
}

enum IndividualAbleType {
    case compare
    case phase
    case concept
}
