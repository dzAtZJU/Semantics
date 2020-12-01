import MapKit
import RealmSwift

enum AnnotationType {
    case visited
    case inSearching
    case inDiscovering
}

class PartnersAnnotation: SemAnnotation {
    var partnerIDs: [String]
    
    init(place: Place, partnerIDs: [String]) {
        self.partnerIDs = partnerIDs
        super.init(place: place, type: .inDiscovering, color: .yellow)
    }
}

class SemAnnotation: MKPointAnnotation {
    let type: AnnotationType
    
    let color: UIColor
    
    let placeID: String?
    
    init(place: Place, type: AnnotationType, color: UIColor) {
        placeID = place._id
        self.type = type
        self.color = color
        
        super.init()
        title = place.title
        coordinate = CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)
    }
    
    init(item: MKMapItem, type: AnnotationType) {
        self.type = type
        placeID = nil
        self.color = .brown
        
        super.init()
        coordinate = item.placemark.coordinate
        title = item.name
    }
}
