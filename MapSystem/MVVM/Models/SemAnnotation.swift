import MapKit
import RealmSwift

enum AnnotationType {
    case visited
    case inSearching
    case inDiscovering
}

class SemAnnotation: MKPointAnnotation {
    let color: UIColor
    
    var placeId: String?
    
    var type: AnnotationType
    
    init(place: Place, type: AnnotationType, color: UIColor) {
        placeId = place._id
        self.type = type
        self.color = color
        super.init()
        title = place.title
        coordinate = CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)
    }
    
    init(item: MKMapItem, type: AnnotationType) {
        self.type = type
        self.color = .brown
        super.init()
        coordinate = item.placemark.coordinate
        title = item.name
    }
}
