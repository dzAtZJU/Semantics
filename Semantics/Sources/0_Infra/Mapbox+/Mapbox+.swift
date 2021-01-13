import Mapbox

extension MGLCoordinateQuad {
    init(_ rect: CGRect) {
        self.init(
            topLeft: .init(rect.bottomLeft),
            bottomLeft: .init(rect.topLeft),
            bottomRight: .init(rect.topRight),
            topRight: .init(rect.bottomRight)
        )
    }
    
    func toTopLeftCounterClockwiseArray() -> [Double] {
        [topLeft, bottomLeft, bottomRight, topRight].flatMap {
            [$0.latitude, $0.longitude]
        }
    }
    
    init(_ fromTopLeftCounterClockwiseArray: [Double]) {
        precondition(fromTopLeftCounterClockwiseArray.count == 8)
        
        self.init(topLeft: .init(latitude: fromTopLeftCounterClockwiseArray[0], longitude: fromTopLeftCounterClockwiseArray[1]),
                  bottomLeft: .init(latitude: fromTopLeftCounterClockwiseArray[2], longitude: fromTopLeftCounterClockwiseArray[3]),
                  bottomRight: .init(latitude: fromTopLeftCounterClockwiseArray[4], longitude: fromTopLeftCounterClockwiseArray[5]),
                  topRight: .init(latitude: fromTopLeftCounterClockwiseArray[6], longitude: fromTopLeftCounterClockwiseArray[7]))
    }
}
 
extension MGLFeature {
    var coords: [CLLocationCoordinate2D] {
        let dic = geoJSONDictionary()
        let geometry = dic["geometry"] as! [String: Any]
        let coordinates = geometry["coordinates"] as! [[[NSNumber]]]
        return coordinates.first!.map {
            CLLocationCoordinate2D(latitude: $0[1].doubleValue, longitude: $0[0].doubleValue)
        }
    }
}
