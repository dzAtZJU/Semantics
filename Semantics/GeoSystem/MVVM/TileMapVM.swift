import UIKit
import CoreLocation
import Mapbox

class ATileMapVM {
    var m: ATileMapM!
    
    func createTile(image: UIImage, coords: [CLLocationCoordinate2D]) -> (URL, MGLCoordinateQuad) {
        let (refedImg, coordinateQuad) = Geo.reference(image: image, coords: coords)
        m.saveReferencedImage(refedImg, coordinateQuad: coordinateQuad)
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(UUID().uuidString)")
        try! refedImg.pngData()!.write(to: url)
        return (url, coordinateQuad)
    }
}
