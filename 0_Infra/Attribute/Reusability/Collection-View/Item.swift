import Foundation

struct TitleItem: Hashable {
    let title: String
    let identifier = UUID()
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}

struct IntepretationBirdItem: Hashable {
    let avatarWithName: ImageWithTitle
    let contentSources: [String]
    
    let identifier = UUID()
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}
