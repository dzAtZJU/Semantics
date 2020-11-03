import Foundation

struct TitleWithImages {
    let title: String
    let images: [ImageWithTitle]
    
    var count: Int {
        images.count
    }
}

struct ImageWithTitle: Hashable {
    let url: URL
    let title: String
    let subtitle: String
    
    let identifier = UUID()
    
    init(url url_: String, title title_: String, subtitle subtitle_: String) {
        url = URL(string: url_)!
        title = title_
        subtitle = subtitle_
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}
