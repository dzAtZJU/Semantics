import UIKit
import MapKit
import CoreLocation
import Combine
import FloatingPanel

protocol AMapVM {
    func loadPlaces()
}

class MapVC: UIViewController {
    private var tintLayer: CALayer?
    
    internal lazy var map: MKMapView = {
        let tmp = MKMapView()
        tmp.mapType = .mutedStandard
        tmp.showsScale = true
        tmp.pointOfInterestFilter = .init(including: [.airport, .amusementPark, .aquarium, .bakery, .beach, .brewery, .cafe, .library, .movieTheater, .nationalPark, .nightlife, .park, .publicTransport, .university, .zoo])
        tmp.isRotateEnabled = false
        tmp.showsUserLocation = true
        tmp.userTrackingMode = .follow
        tmp.region.span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        tmp.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tmp.delegate = self
        return tmp
    }()
    
    private class SemFloatingPanelLayout: FloatingPanelLayout {
        var position: FloatingPanelPosition = .bottom
        
        var initialState: FloatingPanelState = .tip
        
        var anchors: [FloatingPanelState : FloatingPanelLayoutAnchoring] = [
            .full: FloatingPanelLayoutAnchor(absoluteInset: 16, edge: .top, referenceGuide: .safeArea),
            .half: FloatingPanelLayoutAnchor(fractionalInset: 0.7, edge: .bottom, referenceGuide: .safeArea),
            .tip: FloatingPanelLayoutAnchor(fractionalInset: 0.3, edge: .bottom, referenceGuide: .safeArea)
        ]
    }
    internal lazy var panel: FloatingPanelController = {
        let tmp = FloatingPanelController(delegate: self)
        tmp.layout = SemFloatingPanelLayout()
        tmp.set(contentViewController: panelContainerVC)
        tmp.contentMode = .fitToBounds
        tmp.delegate = panelContainerVC
        return tmp
    }()
    
    lazy var panelContainerVC: PanelContainerVC = {
        let tmp = PanelContainerVC(initialVC: searchVC)
        tmp.view.backgroundColor = .systemBackground
        tmp.delegate = self
        return tmp
    }()
    
    private lazy var searchVC: SearchVC = {
        let tmp = SearchVC()
        tmp.panelContentDelegate = self
        return tmp
    }()
    
    private lazy var placeStoryVC: PlaceStoryVC = {
        let tmp = PlaceStoryVC(style: .Plain)
        tmp.panelContentDelegate = self
        tmp.delegate = self
        return tmp
    }()
    
    private lazy var placeStoriesVC: PlaceStoriesVC = {
        let tmp = PlaceStoriesVC(vm: PlaceStoriesVM())
        tmp.allowsEditing = false
        tmp.panelContentDelegate = self
        return tmp
    }()
    
    private var discoverNextVC: DiscoverNextVC {
        let tmp = DiscoverNextVC(vm: mapVM.discoverNextVM)
        tmp.panelContentDelegate = self
        return tmp
    }
    
    private var centerToUserLocation = true
    
    private var annotationsToken: AnyCancellable?
    private var boundingRegionToken: AnyCancellable?
    private var selectedAnnotationToken: AnyCancellable?
    private var selectedPlaceStateToken: AnyCancellable?
    
    internal let mapVM: MapVM
    init(vm vm_: MapVM) {
        mapVM = vm_
        super.init(nibName: nil, bundle: nil)
        tabBarItem = mapVM.tabBarItem
        mapVM.annotationsModel = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = UIView()
        view.addSubview(map)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        panel.addPanel(toParent: self)
        
        selectedAnnotationToken = mapVM.$selectedAnnotationEvent.removeDuplicates(by: { (a, b) -> Bool in
            a.0 == b.0
        }).sink { newEvent in
            guard !self.mapVM.selectedAnnotationEventLock else {
                return
            }
            
            switch newEvent.1 {
            case .onlyMap:
                if let newValue = newEvent.0 {
                    self.map.selectAnnotation(newValue, animated: true)
                } else {
                    self.map.deselectAnnotation(self.map.selectedAnnotations.first, animated: true)
                }
            case .fromModel:
                if let newValue = newEvent.0 {
                    self.map.selectAnnotation(newValue, animated: true)
                    self.panelContentFor(newValue) { panelContent in
                        DispatchQueue.main.async {
                            self.panelContainerVC.show(panelContent, sender: nil)
                        }
                    }
                } else {
                    self.map.deselectAnnotation(self.map.selectedAnnotations.first, animated: true)
                    self.panelContainerVC.hideAll()
                }
            case .fromView:
                self.panelContainerVC.hideAll()
                if let newValue = newEvent.0 {
                    self.panelContentFor(newValue) { panelContent in
                        DispatchQueue.main.async {
                            self.panelContainerVC.show(panelContent, sender: nil)
                        }
                    }
                }
            }
        }
        
        boundingRegionToken = mapVM.$boundingRegion.sink {
            if $0 != nil {
                self.map.region = $0!
                print("map.region \(self.map.region)")
            }
        }
        
        map.addAnnotations(mapVM.annotion())
        map.register(MKAnnotationView.self, forAnnotationViewWithReuseIdentifier: Self.annotationViewIdentifier)
        map.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: Self.markAnnotationViewIdentifier)
        
        NotificationCenter.default.addObserver(forName: .realmsPreloaded, object: nil, queue: nil) { _ in
            self.mapVM.loadPlaces()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        map.frame = view.bounds
        if let tintColor = mapVM.tintColor, tintLayer == nil {
            tintLayer = CALayer()
            tintLayer!.backgroundColor = tintColor.withAlphaComponent(0.005).cgColor
            view.layer.addSublayer(tintLayer!)
        }
        tintLayer?.frame = view.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mapVM.requestLocationAuthorization()
    }
    
    deinit {
        annotationsToken?.cancel()
        annotationsToken = nil
        
        boundingRegionToken?.cancel()
        boundingRegionToken = nil
        
        selectedAnnotationToken?.cancel()
        selectedAnnotationToken = nil
    }
}

// MARK: PlaceStoryDelegate
extension MapVC: PlaceStoryDelegate {
    func placeStoryVCShouldStartIndividualAble(_ placeVC: PlaceStoryVC, tag: String) {
        switch tag {
        case Concept.Seasons.title:
            DispatchQueue.main.async {
                let vc = PhasesVC(seasonsVM: SeasonsVM(placeID: self.mapVM.selectedPlaceId!))
                vc.prevPanelState = .tip
                vc.panelContentDelegate = self
                self.panelContainerVC.show(vc, sender: nil)
            }
        case Concept.Scent.title, Concept.Trust.title:
            DispatchQueue.main.async {
                let vm = ConceptVM(concept: Concept.map[tag]!, placeID: self.mapVM.selectedPlaceId!)
                let vc = PanelNavigationController(rootViewController: ConceptVC(vm: vm))
                vc.prevPanelState = .tip
                vc.panelContentDelegate = self
                self.panelContainerVC.show(vc, sender: nil)
            }
        default:
            _ = FeedbackVM(placeId: self.mapVM.selectedPlaceId!) { vm in
                let vc = FeedbackVC(feedbackVM: vm)
                vc.panelContentDelegate = self
                DispatchQueue.main.async {
                    self.panelContainerVC.show(vc, sender: nil)
                }
            }
        }
    }
    
    func placeStoryVCShouldHumankindAble(_ placeVC: PlaceStoryVC, tag: String) {
        switch tag {
        case Concept.Seasons.title, Concept.Scent.title:
            DispatchQueue.main.async {
//                let v = TalksVC(vm: TalksVM(placeID: self.mapVM.selectedPlaceId!))
//                let nv = UINavigationController(rootViewController: v)
//                self.present(nv, animated: true, completion: nil)
                fatalError()
            }
        default:
            DispatchQueue.main.async {
                self.panelContainerVC.show(self.discoverNextVC, sender: nil)
            }
        }
    }
}

// MARK: MKMapViewDelegate
extension MapVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        guard centerToUserLocation else {
            return
        }
        
        centerToUserLocation = false
        mapView.centerCoordinate = userLocation.coordinate
        MapSysEnvironment.shared.userCurrentCoordinate = userLocation.coordinate
    }
    
    static let annotationViewIdentifier = "annotationView"
    static let markAnnotationViewIdentifier = "markAnnotationView"
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !annotation.isKind(of: MKUserLocation.self) else {
            return nil
        }
        
        let annotation = annotation as! SemAnnotation
        switch annotation.type {
        case .visited:
            let view = mapView.dequeueReusableAnnotationView(withIdentifier: Self.annotationViewIdentifier, for: annotation)
            view.canShowCallout = true
            
            view.image = AnnotationView.createPointImage(color: annotation.color)
            return view
        case .inSearching, .inDiscovering:
            let view =  mapView.dequeueReusableAnnotationView(withIdentifier: Self.markAnnotationViewIdentifier, for: annotation) as! MKMarkerAnnotationView
            view.displayPriority = .required
            view.canShowCallout = true
            view.animatesWhenAdded = true
            return view
        }
    }
    
    // MARK: Interaction
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation as? SemAnnotation else {
            return
        }
        
        mapVM.setSelectedAnnotationEvent((annotation, .fromView))
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        guard let annotation = view.annotation as? SemAnnotation else {
            return
        }
        
        if annotation.type == .inSearching {
            mapVM.removeAnnotations(type: .inSearching)
        }
        mapVM.setSelectedAnnotationEvent((nil, .fromView))
    }
    
    func panelContentFor(_ annotation: SemAnnotation, completion: @escaping (PanelContent) -> Void) {
        if mapVM.circleOfTrust == .private {
            completion(placeStoriesVC)
        } else {
            PlaceStoryVM.new(placeID: annotation.placeId, allowsCondition: mapVM.circleOfTrust == .public) { vm in
                vm.parent = self.mapVM
                DispatchQueue.main.async {
                    self.placeStoryVC.vm = vm
                    completion(self.placeStoryVC)
                }
            }
        }
    }
}

// MARK: FloatingPanelControllerDelegate
extension MapVC: FloatingPanelControllerDelegate {
    
}

// MARK: PanelContentDelegate
extension MapVC: PanelContentDelegate {
    
}


extension MapVC: MapVMAnnotationsModel {
    func addAnnotations(_ annos: [SemAnnotation]) {
        self.map.addAnnotations(annos)
    }
    
    func removeAnnotations(_ annos: [SemAnnotation]) {
        self.map.removeAnnotations(annos)
    }
    
    var annotations: [SemAnnotation] {
        map.annotations.filter {
            $0 is SemAnnotation
            } as! [SemAnnotation]
    }
}

extension MapVC: PanelContainerVCDelegate {
    func panelContentVCWillBack(_ panelContentVC: PanelContainerVC) {
        
    }
    
    func panelContentVC(_ panelContentVC: PanelContainerVC, didShow panelContent: PanelContent, animated: Bool) {
        
    }
    
    func panelContentVC(_ panelContentVC: PanelContainerVC, willHide panelContent: PanelContent, animated: Bool) {
        
    }
}

