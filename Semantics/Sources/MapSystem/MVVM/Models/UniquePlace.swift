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

enum PalceType: Int {
    case compare
    case seasons
    case scent
}
