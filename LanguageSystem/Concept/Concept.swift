struct Perspective {
    static let all: [String] = [
        "Seasons"
    ]
    
    static let Seasons = "Seasons"
    static let Scenery = "Scenery"
    static let Period = "Period"
}

struct ConceptLink: Hashable {
    static let Comparison = ConceptLink(title: "Comparison")
    
    static let Illustrates = ConceptLink(title: "Illustrates")
    
    let title: String
}

struct Concept {
    static func load() {
        Concept.Seasons.map[ConceptLink.Comparison] = [Concept.Scenery]
        Concept.Seasons.map[ConceptLink.Illustrates] = [Concept.Period]
        
        Concept.Scenery.map[ConceptLink.Comparison] = [Concept.Seasons]
    }
    
    static var Seasons = Concept(title: "Seasons")
    
    static var Scenery = Concept(title: "Scenery")
    
    static let Period = Concept(title: "Period")
    
    let title: String
    var map: [ConceptLink: [Concept]] = [:]
}
