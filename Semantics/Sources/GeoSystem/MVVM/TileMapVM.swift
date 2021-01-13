import UIKit
import CoreLocation
import Mapbox
import Combine

class ATileMapVM {
    var m: ATileMapM! {
        didSet {
            pub = m.pub
                .map {
                    MGLImageSource(identifier: $0.key, coordinateQuad: MGLCoordinateQuad($0.quadCoordinates), url: $0.url)
                }
                .eraseToAnyPublisher()
        }
    }
    
    private(set) var pub: AnyPublisher<MGLImageSource, Never>!
    
    init(on queue: DispatchQueue) {}
    
    func generateTile(image: UIImage, coords: [CLLocationCoordinate2D]) -> MGLImageSource {
        let (refedImg, coordinateQuad) = Geo.reference(image: image, coords: coords)
        let identifier = UUID().uuidString
        m.saveTile(refedImg, coordinateQuad: coordinateQuad.toTopLeftCounterClockwiseArray(), identifier: identifier)
        return MGLImageSource(identifier: identifier, coordinateQuad: coordinateQuad, image: refedImg)
    }
}
