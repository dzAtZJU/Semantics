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
    
    private lazy var panel: FloatingPanelController = {
        let tmp = FloatingPanelController(delegate: self)
//        tmp.set(contentViewController: ConditionsVC(vm: vm.conditionsVM))
        tmp.set(contentViewController: panelContentVC)
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
        
        annotationsToken = vm.$annotations.sink {
            self.map.addAnnotations($0)
        }
        boundingRegionToken = vm.$boundingRegion.sink {
            if $0 != nil {
                self.map.region = $0!
            }
        }
        map.addAnnotations(vm.annotations)
        map.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: Self.annotationViewIdentifier)
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
    func mapView(_ mapView: MKMapView, fviewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !annotation.isKind(of: MKUserLocation.self) else {
            return nil
        }

        let view = mapView.dequeueReusableAnnotationView(withIdentifier: Self.annotationViewIdentifier, for: annotation) as! MKMarkerAnnotationView
        view.canShowCallout = true
        return view
    }
    
    // MARK: Interaction
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        vm.selectedAnnotation = view.annotation
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        vm.selectedAnnotation = nil
    }
}
