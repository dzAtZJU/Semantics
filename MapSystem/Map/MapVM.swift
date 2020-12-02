import Foundation
import MapKit
import CoreLocation
import RealmSwift
import Combine

enum EventSource {
    case fromModel
    case fromView
    case onlyMap
}

enum CircleOfTrust {
    case `public`
    case `private`
}

class MapVM: AMapVM {
    private var signedInSubscriber: AnyCancellable?
    
    override init(circleOfTrust: CircleOfTrust) {
        super.init(circleOfTrust: circleOfTrust)
    
        NotificationCenter.default.addObserver(self, selector: #selector(clientReset), name: .clientReset, object: nil)  
    }
    
    override func load(completion: @escaping () -> ()) {
        let trust = circleOfTrust
        RealmSpace.userInitiated.async {
            RealmSpace.userInitiated.privatRealm { privateRealm in
                RealmSpace.userInitiated.publicRealm { publicRealm in
                    let annos = try! publicRealm.queryPlaces(_ids: privateRealm.loadUserPlaceIDsRequire(publicConcept: trust == .public, privateConcept: trust == .private)).map { place throws in
                        SemAnnotation(place: place, type: .visited)
                        //Int.random(in: 0..<3) % 3 == 0 ? .brown: .cyan
                    }
                    
                    DispatchQueue.main.async {
                        self.mapVC.map.addAnnotations(annos)
                        completion()
                    }
                }
            }
        }
    }
    
    override func collectPlace(completion: @escaping (Place, PlaceStory) -> ()) {
        super.collectPlace { (place, placeStory) in
            completion(place, placeStory)
            
            DispatchQueue.main.async {
                self.mapVC.map.deselectAnnotation(nil, animated: true)
                let newAnnotation = SemAnnotation(place: place, type: .visited)
                self.mapVC.map.addAndSelect(newAnnotation)
            }
        }
    }
    
    var selectedAnnotationEventLock = false
    
    @Published private(set) var boundingRegion: MKCoordinateRegion?
    
    var signedIn: (() -> Void)?

    func annotion(filter: ((SemAnnotation) -> Bool)? = nil) -> [SemAnnotation] {
        guard let filter = filter else {
            return []
        }
        return (self.mapVC.map.annotations as! [SemAnnotation]).filter(filter)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: Notification
extension MapVM {
    @objc private func clientReset(notification: Notification) {
        //       ready += 1
        //        if ready == 2 {
        //            ready = 0
        //            loadVisitedPlaces()
        //            signedIn?()
        //        }
    }
}
