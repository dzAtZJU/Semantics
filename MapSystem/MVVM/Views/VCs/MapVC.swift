//
//  MapVC.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/8/6.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Combine
import AddressBook
import FloatingPanel

class MapVC: UIViewController {
    private lazy var panelContentVC: PanelContentVC = {
        let tmp = PanelContentVC()
        tmp.delegate = self
        return tmp
    }()
    
    private lazy var conditionsVC: ConditionsVC = {
        let tmp = ConditionsVC(vm: vm.conditionsVM)
        tmp.delegate = self
        return tmp
    }()
    
    private lazy var panel: FloatingPanelController = {
        let tmp = FloatingPanelController(delegate: self)
        tmp.set(contentViewController: conditionsVC)
        tmp.contentMode = .fitToBounds
        return tmp
    }()
    
    private lazy var map: MKMapView = {
        let tmp = MKMapView()
        tmp.mapType = .mutedStandard
        tmp.showsScale = true
        tmp.pointOfInterestFilter = .init(including: [.airport, .amusementPark, .aquarium, .bakery, .beach, .brewery, .cafe, .library, .movieTheater, .nationalPark, .nightlife, .park, .publicTransport, .university, .zoo])
        tmp.isRotateEnabled = false
        tmp.showsUserLocation = true
        tmp.userTrackingMode = .follow
        tmp.region.span = MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.3)
        tmp.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tmp.delegate = self
        return tmp
    }()
    
    private var centerToUserLocation = true
    
    private var annotationsToken: AnyCancellable?
    private var boundingRegionToken: AnyCancellable?
    
    private let vm: MapVM
    init(vm vm_: MapVM) {
        vm = vm_
        super.init(nibName: nil, bundle: nil)
        vm.signedIn = {
            self.panel.addPanel(toParent: self)
        }
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
        
        annotationsToken = vm.$annotations.sink { value in
            DispatchQueue.main.async {
                self.map.removeAnnotations(self.map.annotations)
                self.map.addAnnotations(value)
            }
        }
        boundingRegionToken = vm.$boundingRegion.sink {
            if $0 != nil {
                self.map.region = $0!
            }
        }
        map.addAnnotations(vm.annotations)
        map.register(MKAnnotationView.self, forAnnotationViewWithReuseIdentifier: Self.annotationViewIdentifier)
        map.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: Self.markAnnotationViewIdentifier)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        map.frame = view.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        vm.requestLocationAuthorization()
    }
    
    deinit {
        annotationsToken?.cancel()
        annotationsToken = nil
        
        boundingRegionToken?.cancel()
        boundingRegionToken = nil
    }
}

extension MapVC: FloatingPanelControllerDelegate {
    
}

extension MapVC: PanelContentVCDelegate {
    func panelContentVC(_ panelContentVC: PanelContentVC, searchDidFinishiWithResponse response: MKLocalSearch.Response) {
        vm.setPlaces(response.mapItems, boundingRegion: response.boundingRegion)
    }
    
    func panelContentVCShouldStartFeedback(_ panelContentVC: PanelContentVC) {
        
            let vc = FeedbackVC(feedbackVM: FeedbackVM(conditionsRank: SemWorldDataLayer.shared.queryCurrentIndividual()!.conditionsRank))
            self.panel.set(contentViewController: vc)
    }
}

extension MapVC: ConditionsVCDelegate {
    func conditionsVCShouldBack() {
        
    }
}

extension MapVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        guard centerToUserLocation else {
            return
        }
        
        centerToUserLocation = false
        mapView.centerCoordinate = userLocation.coordinate
        panelContentVC.updateUserLocation(userLocation.coordinate)
    }
    
    static let annotationViewIdentifier = "annotationView"
    static let markAnnotationViewIdentifier = "markAnnotationView"
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !annotation.isKind(of: MKUserLocation.self) else {
            return nil
        }

        
        if annotation is SemAnnotation1 {
            let view =  mapView.dequeueReusableAnnotationView(withIdentifier: Self.markAnnotationViewIdentifier, for: annotation) as! MKMarkerAnnotationView
            view.canShowCallout = true
            view.animatesWhenAdded = true
            return view
        }
        
        let view = mapView.dequeueReusableAnnotationView(withIdentifier: Self.annotationViewIdentifier, for: annotation)
        view.canShowCallout = true
        let size = CGSize(width: 10, height: 10)
        view.image = UIGraphicsImageRenderer(size: size).image { context in
            UIImage(systemName:"circle.fill")!.withTintColor(.brown).draw(in:CGRect(origin:.zero, size: size))
        }
        return view
    }
    
    // MARK: Interaction
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        vm.setSelectedAnnotation(view.annotation as! SemAnnotation)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        vm.setSelectedAnnotation(nil)
    }
}
