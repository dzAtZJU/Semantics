import RealmSwift
import Mapbox

class RLMStringCoordinateQuad: EmbeddedObject {
    @objc dynamic var aws3Key = ""
    
    let coordinateQuad = RealmSwift.List<Double>()
    
    convenience init(aws3Key: String, coordinateQuad: MGLCoordinateQuad) {
        self.init()
        self.aws3Key = aws3Key
        self.coordinateQuad.append(objectsIn: coordinateQuad.toArray())
    }
}

extension Realm {
    func addTile(aws3Key: String, coordinateQuad: MGLCoordinateQuad) {
        let ind = queryCurrentIndividual()!
        try! write {
            ind.tile_List.append(RLMStringCoordinateQuad(aws3Key: aws3Key, coordinateQuad: coordinateQuad))
        }
    }
}

extension MGLCoordinateQuad {
    func toArray() -> [Double] {
        [topLeft, bottomLeft, bottomRight, topRight].flatMap {
            [$0.latitude, $0.longitude]
        }
    }
}
