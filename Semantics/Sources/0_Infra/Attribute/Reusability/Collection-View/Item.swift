import Foundation
        
struct IntepretationBirdItem: Hashable {
    let avatarWithName: ImageWithTitle
    let contentSources: [String]
    
    let identifier = UUID()
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}
