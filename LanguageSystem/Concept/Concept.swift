struct ConceptLink: Hashable {
    static let Comparison = ConceptLink(title: "Comparison")
    
    static let Illustrates = ConceptLink(title: "Illustrates")
    
    let title: String
}

struct Concept {
    static func load() {
        Concept.Seasons.map[ConceptLink.Comparison] = [Concept.Scenery, Concept.Period, Concept.Seasons]
        Concept.Seasons.map[ConceptLink.Illustrates] = [Concept.Period]
        
        Concept.Scenery.map[ConceptLink.Comparison] = [Concept.Seasons]
    }
    
    static var all: [Concept] {
        [Seasons]
    }
    
    static var allTitles: [String] {
        all.map(\.title)
    }
    
    static var Seasons = Concept(title: "Seasons")
    
    static var Scenery = Concept(title: "Scenery")
    
    static let Period = Concept(title: "Period")
    
    let title: String
    var map: [ConceptLink: [Concept]] = [:]
}
