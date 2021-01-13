import CoreLocation
import Mapbox
import SemGeometry
import Metron

enum Geo {
    static func reference(image: UIImage, coords: [CLLocationCoordinate2D]) -> (UIImage, MGLCoordinateQuad) {
        let boundingBox = Geometry.boundingBox(ofPolygon: coords.map({ CGPoint($0)}))
        var imageBox = CGRect(aspectFitSize: image.size, inRect: boundingBox)
        // cos(lat) * delta_lon = delta_lat
        let newHeight = cos(Angle(imageBox.minLatitude, unit: .degrees).radians) * imageBox.height
        let insetY = (imageBox.height - newHeight) / 2
        imageBox = imageBox.insetBy(dx: 0, dy: insetY)
        return (image, MGLCoordinateQuad(imageBox))
    }
}
