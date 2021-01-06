import Amplify
import Mapbox
import RealmSwift
import SemLog
import Combine

class ATileMapM {
    func saveReferencedImage(_ image: UIImage, coordinateQuad: MGLCoordinateQuad) {
        let key = "\(RealmSpace.userID!).\(UUID())"
        var cancellable: AnyCancellable?
        cancellable = Amplify.Storage.uploadData(key: key, data: image.pngData()!).resultPublisher
            .sink {
                if case let .failure(error) = $0 {
                    SemLog.capture(error: error)
                }
                cancellable = nil
            } receiveValue: { url in
                SemLog.capture(message: "[AWS3: \(url)]")
            }
    }
}

class RLMStringCoordinateQuad: EmbeddedObject {
    @objc dynamic var aws3Key = ""
    
    let coordinateQuad = RealmSwift.List<Double>()
    
    convenience init(aws3Key: String, coordinateQuad: MGLCoordinateQuad) {
        self.init()
        self.aws3Key = aws3Key
        self.coordinateQuad.append(objectsIn: coordinateQuad.toArray())
    }
}

extension MGLCoordinateQuad {
    func toArray() -> [Double] {
        [topLeft, bottomLeft, bottomRight, topRight].flatMap {
            [$0.latitude, $0.longitude]
        }
    }
}
