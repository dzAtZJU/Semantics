import MapKit

struct UniquePlace {
    let title: String
    let latitude: Double
    let longitude: Double
    
    init(annotation: MKAnnotation) {
        title = annotation.title!!
        latitude = annotation.coordinate.latitude
        longitude = annotation.coordinate.longitude
    }
}

enum Uniqueness: Int {
    case ordinary
    case unique
}
