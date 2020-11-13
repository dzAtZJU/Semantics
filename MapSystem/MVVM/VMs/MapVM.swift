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
            return .systemYellow
        case .private:
            return nil
        }
    }
    
    init(circleOfTrust: CircleOfTrust) {
        self.circleOfTrust = circleOfTrust
        
        signedInSubscriber = RealmSpace.signedInCurrentValueSubject!.sink { value in
            guard value == 1 else {
                return
            }
            self.loadVisitedPlaces()
//            RealmSpace.signedInCurrentValueSubject = nil
            self.signedInSubscriber = nil
        }
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
        RealmSpace.shared.queue.sync {
            let dataLayer = SemWorldDataLayer(realm: RealmSpace.shared.realm(RealmSpace.queryCurrentUserID()!))
            tmp = DiscoverNextVM(placeId: selectedAnnotation!.placeId!, conditionIDs: dataLayer.queryConditionIDs(forPlace: selectedAnnotation!.placeId!))
            tmp.panelContentVMDelegate = self
        }
        return tmp
    }
}

// MARK: Places
extension MapVM {
    func loadVisitedPlaces() {
        let trust = circleOfTrust
        RealmSpace.shared.async {
            RealmSpace.shared.realm(RealmSpace.queryCurrentUserID()!) { privateRealm in
                RealmSpace.shared.realm(RealmSpace
                                            .partitionValue) { publicRealm in
                    let annos = try! SemWorldDataLayer(realm: publicRealm).queryPlaces(_ids: SemWorldDataLayer(realm: privateRealm).loadVisitedPlacesRequire(publicConcept: trust == .public, privateConcept: trust == .private)).map { place throws in
                        SemAnnotation(place: place, type: .visited)
                    }
                    
                    DispatchQueue.main.async {
                        self.appendAnnotations(annos)
                    }
                }
            }
        }
    }
    
    func markVisited() {
        let uniquePlace = UniquePlace(annotation: self.selectedAnnotation!)
        RealmSpace.shared.async {
            let place = SemWorldDataLayer(realm: RealmSpace.shared.realm(RealmSpace.partitionValue)).queryOrCreatePlace(uniquePlace).freeze()
            
            SemWorldDataLayer(realm: RealmSpace.shared.realm(RealmSpace.queryCurrentUserID()!)).markVisited(placeID: place._id)
            DispatchQueue.main.async {
                self.setSelectedAnnotationEvent((nil, .fromModel))
                let newAnnotation = SemAnnotation(place: place, type: .visited)
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

extension MapVM: PanelContentVMDelegate {
    var mapVM: MapVM {
        self
    }
}
