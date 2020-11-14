import MapKit
import RealmSwift

enum AnnotationType {
    case visited
    case inSearching
    case inDiscovering
}

class SemAnnotation: MKPointAnnotation {
    var placeId: String?
    var type: AnnotationType
    init(place: Place, type type_: AnnotationType) {
        placeId = place._id
        type = type_
        super.init()
        title = place.title
        coordinate = CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)
    }
    
    init(item: MKMapItem, type type_: AnnotationType) {
        type = type_
        super.init()
        coordinate = item.placemark.coordinate
        title = item.name
    }
}
