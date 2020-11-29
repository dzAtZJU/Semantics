import UIKit
import MapKit
import CoreLocation
import Combine
import FloatingPanel
import Presentr
import SPAlert

class AMapVM: NSObject {
    var mapVC: MapVC!
    
    let circleOfTrust: CircleOfTrust
    
    init(circleOfTrust: CircleOfTrust) {
        self.circleOfTrust = circleOfTrust
    }
    
    func loadPlaces(completion: @escaping () -> ()) {
        fatalError()
    }
    
    func collectPlace(completion: @escaping (Place, PlaceStory) -> ()) {
        let uniquePlace = UniquePlace(annotation: mapVC.map.selectedAnnotations.first!)
        RealmSpace.userInitiated.async {
            let place = RealmSpace.userInitiated.publicRealm.queryOrCreatePlace(uniquePlace).freeze()
            
            let placeStory = RealmSpace.userInitiated.privatRealm.collectPlace(placeID: place._id)
            
            completion(place, placeStory)
        }
    }
    
    func addPartner(_ partnerID: String, completion: @escaping (Profile) ->  ()) {
        RealmSpace.userInitiated.async {
            RealmSpace.userInitiated.addPartner(partnerID) { profile in
                self.loadPlaces {
                    completion(profile)
                }
            }
        }
    }
}

class MapVC: UIViewController {
    private lazy var spinner = Spinner.create()
    
    private var tintLayer: CALayer?
    
    internal lazy var map: MKMapView = {
        let tmp = MKMapView()
        tmp.mapType = .mutedStandard
        tmp.pointOfInterestFilter = .init(including: [.airport, .amusementPark, .aquarium, .bakery, .beach, .brewery, .cafe, .library, .movieTheater, .nationalPark, .nightlife, .park, .publicTransport, .university, .zoo])
        tmp.isRotateEnabled = false
        tmp.showsUserLocation = true
        tmp.userTrackingMode = .follow
        tmp.region.span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        tmp.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tmp.delegate = self
        return tmp
    }()
    
    private lazy var profileBtn = UIButton(systemName: "person.circle.fill", textStyle: .title2, primaryAction: UIAction(handler: { _ in
        let vc = ProfileVC()
        vc.view.widthAnchor.constraint(equalToConstant: self.view.width).isActive = true
        self.customPresentViewController(vc.presentr, viewController: vc, animated: true, completion: nil)
    }))
    
    private class SemFloatingPanelLayout: FloatingPanelLayout {
        var position: FloatingPanelPosition = .bottom
        
        var initialState: FloatingPanelState = .tip
        
        var anchors: [FloatingPanelState : FloatingPanelLayoutAnchoring] = [
            .full: FloatingPanelLayoutAnchor(absoluteInset: 16, edge: .top, referenceGuide: .safeArea),
            .half: FloatingPanelLayoutAnchor(fractionalInset: 0.7, edge: .bottom, referenceGuide: .safeArea),
            .tip: FloatingPanelLayoutAnchor(fractionalInset: 0.2, edge: .bottom, referenceGuide: .safeArea)
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
        let tmp = PlaceStoriesVC()
        tmp.allowsEditing = false
        tmp.panelContentDelegate = self
        tmp.placeStoryVCDelegate = self
        return tmp
    }()
    
    private var discoverNextVC: DiscoverNextVC {
        let tmp = DiscoverNextVC(vm: discoverNextVM)
        tmp.panelContentDelegate = self
        return tmp
    }
    
    private var discoverNextVM: DiscoverNextVM {
        var tmp: DiscoverNextVM!
        RealmSpace.userInitiated.queue.sync {
            let dataLayer = RealmSpace.userInitiated.privatRealm
            tmp = DiscoverNextVM(placeId: selectedAnnotation!.placeID!, conditionIDs: dataLayer.queryConditionIDs(forPlace: selectedAnnotation!.placeID!))
        }
        return tmp
    }
    
    private var centerToUserLocation = true
    
    private var annotationsToken: AnyCancellable?
    private var boundingRegionToken: AnyCancellable?
    
    internal let vm: AMapVM
    
    private var selectedAnnotation: SemAnnotation? {
        map.selectedAnnotations.first as? SemAnnotation
    }
    
    private var selectedPlaceID: String? {
        selectedAnnotation?.placeID
    }
    
    private lazy var locationManager: CLLocationManager = {
        let tmp = CLLocationManager()
        return tmp
    }()
    
    init(vm: AMapVM) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
        vm.mapVC = self
        
        tabBarItem = {
            switch vm.circleOfTrust {
            case .public:
                let img = UIImage(systemName: "hand.point.up.braille.fill")?.withBaselineOffset(fromBottom: UIFont.systemFontSize/4)
                return UITabBarItem(title: "Public", image: img, selectedImage: img)
            case .private:
                let img = UIImage(systemName: "heart.fill")
                return UITabBarItem(title: "Wish List", image: img, selectedImage: img)
            }
        }()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = UIView()
        view.addSubview(map)
        
        if vm.circleOfTrust == .private {
            view.addSubview(profileBtn)
            profileBtn.anchorTopLeading()
        }
        
        view.addSubview(spinner)
        spinner.anchorCenterSuperview()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        panel.addPanel(toParent: self)
        
        map.register(MKAnnotationView.self, forAnnotationViewWithReuseIdentifier: Self.annotationViewIdentifier)
        map.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: Self.markAnnotationViewIdentifier)
        
        if RealmSpace.isPreloaded {
            self.loadPlaces()
        } else {
            NotificationCenter.default.addObserver(forName: .realmsPreloaded, object: nil, queue: nil) { _ in
                self.loadPlaces()
            }
        }
        
        NotificationCenter.default.addObserver(forName: .searchFinished, object: nil, queue: nil) {
            let response = $0.object as! MKLocalSearch.Response
            self.map.region = response.boundingRegion
            
            let newAnno = response.mapItems.map({
                SemAnnotation(item: $0, type: .inSearching)
            }).first!
            self.map.addAndSelect(newAnno)
        }
        
        if vm.circleOfTrust == .private {
            NotificationCenter.default.addObserver(forName: .inviteReceived, object: nil, queue: nil) { notification in
                guard let inviter = notification.object as? String, inviter != RealmSpace.userID else {
                    return
                }
                
                DispatchQueue.main.async {
                    self.spinner.startAnimating(parent: self.view)
                    self.vm.addPartner(inviter) { profile in
                        DispatchQueue.main.async {
                            self.spinner.stopAnimating()
                            SPAlert.present(title: profile.name, message: "We are friends now", image: profile.image)
                        }
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        locationManager.requestWhenInUseAuthorization()
    }
    
    private func loadPlaces() {
        spinner.startAnimating()
        vm.loadPlaces {
            self.spinner.stopAnimating()
        }
    }
    
    deinit {
        annotationsToken?.cancel()
        annotationsToken = nil
        
        boundingRegionToken?.cancel()
        boundingRegionToken = nil
    }
}

// MARK: PlaceStoryDelegate
extension MapVC: PlaceStoryVCDelegate {
    func placeStoryVCShouldStartIndividualAble(_ placeVC: PlaceStoryVC, tag: String) {
        switch tag {
        case Concept.Seasons.title:
            DispatchQueue.main.async {
                let vc = PhasesVC(seasonsVM: SeasonsVM(placeID: self.selectedPlaceID!))
                vc.prevPanelState = .tip
                vc.panelContentDelegate = self
                self.panelContainerVC.show(vc, sender: nil)
            }
        case Concept.Scent.title, Concept.Trust.title:
            DispatchQueue.main.async {
                let vm = ConceptVM(concept: Concept.map[tag]!, placeID: self.selectedPlaceID!, ownerID: placeVC.vm.ownerID)
                let vc = PanelNavigationController(rootViewController: ConceptVC(vm: vm))
                vc.prevPanelState = .tip
                vc.panelContentDelegate = self
                self.panelContainerVC.show(vc, sender: nil)
            }
        default:
            _ = FeedbackVM(placeId: selectedPlaceID!) { vm in
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
        case .visited, .inDiscovering:
            let view = mapView.dequeueReusableAnnotationView(withIdentifier: Self.annotationViewIdentifier, for: annotation)
            view.canShowCallout = true
            
            view.image = AnnotationView.createPointImage(color: annotation.color)
            return view
        case .inSearching:
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
        
        panelContainerVC.hideAll()
        
        self.panelContentFor(annotation) { panelContent in
            DispatchQueue.main.async {                    self.panelContainerVC.show(panelContent, sender: nil)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        panelContainerVC.hideAll()
        
        if view is MKMarkerAnnotationView {
            mapView.removeAnnotation(view.annotation!)
        }
    }
    
    func panelContentFor(_ annotation: SemAnnotation, completion: @escaping (PanelContent) -> Void) {
        if let anno = annotation as? PartnersAnnotation {
            PlaceStoriesVM.new(placeID: anno.placeID!, partnersID: anno.partnerIDs) { vm in
                self.placeStoriesVC.vm = vm
                completion(self.placeStoriesVC)
            }
        } else {
            PlaceStoryVM.new(placeID: annotation.placeID, allowsCondition: vm.circleOfTrust == .public) { vm in
                vm.parent = self.vm
                RealmSpace.main.async {
                    vm.partnerProfile = RealmSpace.main.privatRealm.queryCurrentIndividual()!.profile
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
    var mapVM: AMapVM {
        vm
    }
    
}

extension MKMapView {
    func addAndSelect(_ annotation: MKAnnotation) {
        addAnnotation(annotation)
        selectAnnotation(annotation, animated: true)
    }
    
    var selectedAnnotation: MKAnnotation? {
        selectedAnnotations.first
    }
}
