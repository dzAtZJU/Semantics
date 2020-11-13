import Foundation

struct TitleItem: Hashable {
    let identifier = UUID()
    
    let isInputing: Bool
    
    let title: String
    
    let type: HeaderType?
    
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
