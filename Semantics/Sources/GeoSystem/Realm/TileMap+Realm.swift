import RealmSwift
import Mapbox

class RLMAWS3KeyCoordinateQuad: EmbeddedObject {
    @objc dynamic var identifier = ""
    
    @objc dynamic var aws3Key = ""
    
    let coordinateQuad = RealmSwift.List<Double>()
    
    convenience init(identifier: String, aws3Key: String, coordinateQuad: [Double]) {
        self.init()
        self.identifier = identifier
        self.aws3Key = aws3Key
        self.coordinateQuad.append(objectsIn: coordinateQuad)
    }
}

extension Realm {
    func addTile(identifier: String, aws3Key: String, coordinateQuad: [Double]) {
        let ind = queryIndividual()
        try! write {
            ind.tile_List.append(RLMAWS3KeyCoordinateQuad(identifier: identifier, aws3Key: aws3Key, coordinateQuad: coordinateQuad))
        }
    }
}
