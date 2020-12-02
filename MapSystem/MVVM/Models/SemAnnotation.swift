import MapKit
import RealmSwift

enum AnnotationType {
    case visited
    case inSearching
    case inDiscovering
}

class PartnersAnnotation: SemAnnotation {
    var partnerIDs: [String]
    
    var sectionsCount: Int {
        min(partnerIDs.count, 4)
    }
    
    init(place: Place, partnerIDs: [String]) {
        self.partnerIDs = partnerIDs
        super.init(place: place, type: .inDiscovering)
    }
}

class SemAnnotation: MKPointAnnotation {
    let type: AnnotationType
    
    let placeID: String?
    
    init(place: Place, type: AnnotationType) {
        placeID = place._id
        self.type = type
        
        super.init()
        title = place.title
        coordinate = CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)
    }
    
    init(item: MKMapItem, type: AnnotationType) {
        self.type = type
        placeID = nil
        
        super.init()
        coordinate = item.placemark.coordinate
        title = item.name
    }
}
