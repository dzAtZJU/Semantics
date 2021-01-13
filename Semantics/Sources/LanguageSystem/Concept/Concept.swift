struct ConceptLink: Hashable {
    static let Comparison = ConceptLink(title: "Comparison")
    
    static let Illustrates = ConceptLink(title: "Illustrates")
    
    static let Instance = ConceptLink(title: "Instance")
    
    static let CanBeTrusted = ConceptLink(title: "Can be trusted")
    
    let title: String
}

struct Concept {
    // MARK: Public
    static var Seasons = Concept(title: "Seasons", isPrivate: false, individualAble: .Describe)
    
    static var Scenery = Concept(title: "Scenery", isPrivate: false, individualAble: .Describe)
    
    static let Period = Concept(title: "Period", isPrivate: false, individualAble: .Describe)
    
    static let Trust = Concept(title: "Trust", isPrivate: false, individualAble: .Describe)
    
    // MARK: Private
    static var Scent = Concept(title: "Scent", isPrivate: true, individualAble: .Experience)
    
    static func load() {
        Seasons.map[ConceptLink.Comparison] = [.Scenery]
        Seasons.map[ConceptLink.Illustrates] = [.Period]
        
        Scenery.map[ConceptLink.Comparison] = [.Seasons]
    }
    
    static var allPublic: [Concept] {
        [Seasons, Trust]
    }
    
    static var allPrivate: [Concept] {
        [Scent]
    }
    
    static let map: [String: Concept] = [
        Concept.Seasons.title: Concept.Seasons,
        Concept.Scent.title: Concept.Scent,
        Concept.Trust.title: Concept.Trust
    ]
    
    static var allPublicTitles: [String] {
        allPublic.map(\.title)
    }
    
    static var allPrivateTitles: [String] {
        allPrivate.map(\.title)
    }
    
    let title: String
    
    let isPrivate: Bool
    
    let individualAble: IndividualAble
    
    var map: [ConceptLink: [Concept]] = [:]
}

enum IndividualAble: String {
    case Compare = "Compare"
    case Describe = "Describe"
    case Experience = "Experience"
    
    var humankindAble: HumankindAble {
        switch self {
        case .Compare:
            return .Search
        case .Describe:
            return .Talks
        case .Experience:
            return .None
        }
    }
}

enum HumankindAble: String {
    case None = ""
    case Talks = "Talks"
    case Search = "Search"
}
