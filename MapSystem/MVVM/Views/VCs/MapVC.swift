import UIKit
import MapKit
import CoreLocation
import Combine
import FloatingPanel

class MapVC: UIViewController {
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
        tmp.set(contentViewController: panelContentVC)
        tmp.contentMode = .fitToBounds
        tmp.delegate = panelContentVC
        return tmp
    }()
    
    lazy var panelContentVC: PanelContentVC = {
        let tmp = PanelContentVC(initialVC: searchVC)
        tmp.view.backgroundColor = .systemBackground
        tmp.delegate = self
        return tmp
    }()
    
    private lazy var searchVC: SearchVC = {
        let tmp = SearchVC()
        tmp.panelContentDelegate = self
        return tmp
    }()
    
    private lazy var placeVC: PlaceVC = {
        let tmp = PlaceVC()
        tmp.panelContentDelegate = self
        tmp.delegate = self
        return tmp
    }()
    
    private var discoverNextVC: DiscoverNextVC {
        let tmp = DiscoverNextVC(vm: mapVM.discoverNextVM)
        tmp.panelContentDelegate = self
        return tmp
    }
    
    private lazy var spinner: UIActivityIndicatorView = {
        let tmp = UIActivityIndicatorView()
        tmp.style = .large
        tmp.color = .systemPurple
        tmp.hidesWhenStopped = true
        return tmp
    }()
    
    private var centerToUserLocation = true
    
    private var annotationsToken: AnyCancellable?
    private var boundingRegionToken: AnyCancellable?
    private var selectedAnnotationToken: AnyCancellable?
    private var selectedPlaceStateToken: AnyCancellable?
    
    internal let mapVM: MapVM
    init(vm vm_: MapVM) {
        mapVM = vm_
        super.init(nibName: nil, bundle: nil)
        mapVM.annotationsModel = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = UIView()
        view.addSubview(map)
        view.addSubview(spinner)
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
                            self.panelContentVC.show(panelContent, sender: nil)
                        }
                    }
                } else {
                    self.map.deselectAnnotation(self.map.selectedAnnotations.first, animated: true)
                    self.panelContentVC.hideAll()
                }
            case .fromView:
                self.panelContentVC.hideAll()
                if let newValue = newEvent.0 {
                    self.panelContentFor(newValue) { panelContent in
                        DispatchQueue.main.async {
                            self.panelContentVC.show(panelContent, sender: nil)
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
        map.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: Self.pinAnnotationViewIdentifier)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        map.frame = view.bounds
        spinner.center = view.center
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

// MARK: PlaceVCDelegate
extension MapVC: PlaceVCDelegate {
    func placeWillDisappear(_ placeVC: PlaceVC) {
    }
    
    func placeVCShouldStartIndividualAble(_ placeVC: PlaceVC) {
        switch placeVC.vm.uniqueness! {
        case .ordinary:
            FeedbackVM(placeId: self.mapVM.selectedPlaceId!) { vm in
                let vc = FeedbackVC(feedbackVM: vm)
                vc.panelContentDelegate = self
                DispatchQueue.main.async {
                    self.panelContentVC.show(vc, sender: nil)
                }
            }
        case .unique:
            DispatchQueue.main.async {
                let vc = SeasonsVC()
                vc.prevPanelState = .tip
                vc.panelContentDelegate = self
                self.panelContentVC.show(vc, sender: nil)
            }
        }
            
    }
    
    func placeVCShouldCollect(_ placeVC: PlaceVC) {
        mapVM.markVisited()
    }
    
    func placeVCShouldHumankindAble(_ placeVC: PlaceVC) {
        DispatchQueue.main.async {
            self.panelContentVC.show(self.discoverNextVC, sender: nil)
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
    static let pinAnnotationViewIdentifier = "markAnnotationView"
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !annotation.isKind(of: MKUserLocation.self) else {
            return nil
        }
        
        let annotation = annotation as! SemAnnotation
        switch annotation.type {
        case .visited:
            let view = mapView.dequeueReusableAnnotationView(withIdentifier: Self.annotationViewIdentifier, for: annotation)
            view.canShowCallout = true
            let size = CGSize(width: 14, height: 14)
            view.image = UIGraphicsImageRenderer(size: size).image { context in
                UIImage(systemName:"circle.fill")!.withTintColor(.brown).draw(in:CGRect(origin:.zero, size: size))
            }
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
        switch annotation.type {
        case .inSearching, .visited:
            PlaceVM.new(placeID: annotation.placeId, uniqueness: annotation.uniqueness) { vm in
                DispatchQueue.main.async {
                    self.placeVC.vm = vm
                    completion(self.placeVC)
                }
            }
        case .inDiscovering:
            fatalError()
        }
        
    }
}

// MARK: FloatingPanelControllerDelegate
extension MapVC: FloatingPanelControllerDelegate {
    
}

// MARK: PanelContentDelegate
extension MapVC: PanelContentDelegate {
    func setSpinning(_ to: Bool) {
        if to {
            view.bringSubviewToFront(spinner)
            spinner.startAnimating()
            view.isUserInteractionEnabled = false
        } else {
            spinner.stopAnimating()
            view.isUserInteractionEnabled = true
        }
    }
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

extension MapVC: PanelContentVCDelegate {
    func panelContentVCWillBack(_ panelContentVC: PanelContentVC) {
        mapVM.setSelectedAnnotationEvent((nil, .fromModel))
    }
    
    func panelContentVC(_ panelContentVC: PanelContentVC, didShow panelContent: PanelContent, animated: Bool) {
        guard let placeId = panelContent.panelContentVM?.thePlaceId else {
            return
        }

        let selectedAnnotation = mapVM.annotion {
            $0.placeId == placeId
        }.first!
        mapVM.setSelectedAnnotationEvent((selectedAnnotation, .onlyMap))
    }
    
    func panelContentVC(_ panelContentVC: PanelContentVC, willHide panelContent: PanelContent, animated: Bool) {
//        guard let _ = panelContent.panelContentVM?.thePlaceId else {
//            return
//        }
//
//        mapVM.setSelectedAnnotationEvent((nil, .fromModel))
    }
}



