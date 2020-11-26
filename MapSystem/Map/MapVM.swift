import Foundation
import MapKit
import CoreLocation
import RealmSwift
import Combine

enum PlaceState: Int {
    case neverBeen = 0
    case visited
    case feedbacked
}

enum EventSource {
    case fromModel
    case fromView
    case onlyMap
}

protocol MapVMAnnotationsModel {
    func addAnnotations(_: [SemAnnotation])
    
    func removeAnnotations(_: [SemAnnotation])
    
    var annotations: [SemAnnotation] {
        get
    }
}

enum CircleOfTrust {
    case `public`
    case `private`
}

class MapVM {
    private var signedInSubscriber: AnyCancellable?
    
    let circleOfTrust: CircleOfTrust
    
    var tabBarItem: UITabBarItem {
        switch circleOfTrust {
        case .public:
            let img = UIImage(systemName: "hand.point.up.braille.fill")?.withBaselineOffset(fromBottom: UIFont.systemFontSize/4)
            return UITabBarItem(title: "Public", image: img, selectedImage: img)
        case .private:
            let img = UIImage(systemName: "heart.fill")
            return UITabBarItem(title: "Wish List", image: img, selectedImage: img)
        }
    }
    
    var tintColor: UIColor? {
        switch circleOfTrust {
        case .public:
            return nil
        case .private:
            return .systemYellow
        }
    }
    
    init(circleOfTrust: CircleOfTrust) {
        self.circleOfTrust = circleOfTrust
        
        NotificationCenter.default.addObserver(self, selector: #selector(clientReset), name: .clientReset, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(searchFinished), name: .searchFinished ,object: nil)
    }
    
    @Published private(set) var selectedAnnotationEvent: (SemAnnotation?, EventSource) = (nil, .fromModel)
    var selectedAnnotationEventLock = false
    
    var annotationsModel: MapVMAnnotationsModel!
    
    private var selectedAnnotation: SemAnnotation? {
        selectedAnnotationEvent.0
    }
    
    var selectedPlaceId: String? {
        selectedAnnotation?.placeId
    }
    
    @Published private(set) var boundingRegion: MKCoordinateRegion?
    
    var signedIn: (() -> Void)?
    
    private lazy var locationManager: CLLocationManager = {
        let tmp = CLLocationManager()
        return tmp
    }()
    
    func requestLocationAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func setSelectedAnnotationEvent(_ event: (SemAnnotation?, EventSource)) {
        selectedAnnotationEvent = event
    }
    
    func appendAnnotations(_ values: [SemAnnotation]) {
        annotationsModel.addAnnotations(values)
    }
    
    func removeAnnotations(type: AnnotationType) {
        let annos = annotationsModel.annotations.filter {
            $0.type == type
        }
        annotationsModel.removeAnnotations(annos)
    }
    
    func annotion(filter: ((SemAnnotation) -> Bool)? = nil) -> [SemAnnotation] {
        guard let filter = filter else {
            return []
        }
        return annotationsModel.annotations.filter(filter)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    var discoverNextVM: DiscoverNextVM {
        var tmp: DiscoverNextVM!
        RealmSpace.userInitiated.queue.sync {
            let dataLayer = RealmSpace.userInitiated.privatRealm
            tmp = DiscoverNextVM(placeId: selectedAnnotation!.placeId!, conditionIDs: dataLayer.queryConditionIDs(forPlace: selectedAnnotation!.placeId!))
        }
        tmp.parent = self
        return tmp
    }
}

// MARK: Places
extension MapVM {
    func loadPlaces() {
        let trust = circleOfTrust
        RealmSpace.userInitiated.async {
            RealmSpace.userInitiated.privatRealm { privateRealm in
                RealmSpace.userInitiated.publicRealm { publicRealm in
                    let annos = try! publicRealm.queryPlaces(_ids: privateRealm.loadVisitedPlacesRequire(publicConcept: trust == .public, privateConcept: trust == .private)).map { place throws in
                        SemAnnotation(place: place, type: .visited, color: UIColor.random)
                        //Int.random(in: 0..<3) % 3 == 0 ? .brown: .cyan
                    }
                    
                    DispatchQueue.main.async {
                        self.appendAnnotations(annos)
                    }
                }
            }
        }
    }
    
    func collectPlace(completion: @escaping (PlaceStory) -> ()) {
        let uniquePlace = UniquePlace(annotation: self.selectedAnnotation!)
        RealmSpace.userInitiated.async {
            let place = RealmSpace.userInitiated.publicRealm.queryOrCreatePlace(uniquePlace).freeze()
            
            let placeStory = RealmSpace.userInitiated.privatRealm.collectPlace(placeID: place._id)
            
            completion(placeStory)
            DispatchQueue.main.async {
                self.setSelectedAnnotationEvent((nil, .fromModel))
                let newAnnotation = SemAnnotation(place: place, type: .visited, color: .brown)
                self.appendAnnotations([newAnnotation])
                self.setSelectedAnnotationEvent((newAnnotation, .fromModel))
            }
        }
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
    @objc private func searchFinished(notification: Notification) {
        let response = notification.object as! MKLocalSearch.Response
        let newAnno = response.mapItems.map({
            SemAnnotation(item: $0, type: .inSearching)
        }).first!
        appendAnnotations([newAnno])
        boundingRegion = response.boundingRegion
        selectedAnnotationEvent = (newAnno, .fromModel)
    }
}
