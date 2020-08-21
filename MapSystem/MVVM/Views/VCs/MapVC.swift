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
import FloatingPanel

class MapVC: UIViewController {
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
    
    internal lazy var panel: FloatingPanelController = {
        let tmp = FloatingPanelController(delegate: self)
        tmp.set(contentViewController: panelContentVC)
        tmp.contentMode = .fitToBounds
        tmp.delegate = panelContentVC
        return tmp
    }()
    
    private lazy var panelContentVC: PanelContentVC = {
        let tmp = PanelContentVC(initialVC: searchVC)
        return tmp
    }()
    
    private lazy var searchVC: SearchVC = {
        let tmp = SearchVC()
        tmp.panelContentDelegate = self
        return tmp
    }()
    
    private lazy var placeVC: PlaceVC = {
        let tmp = PlaceVC(vm: vm.placeVM)
        tmp.panelContentDelegate = self
        tmp.delegate = self
        return tmp
    }()
    
    private lazy var discoverNextVC: DiscoverNextVC = {
        let tmp = DiscoverNextVC(vm: vm.discoverNextVM)
        tmp.panelContentDelegate = self
        return tmp
    }()
    
    private var centerToUserLocation = true
    
    private var annotationsToken: AnyCancellable?
    private var boundingRegionToken: AnyCancellable?
    private var searchResultAnnotationsToken: AnyCancellable?
    private var selectedAnnotationsToken: AnyCancellable?
    
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
                self.map.removeAnnotations(self.vm.annotations)
                self.map.addAnnotations(value)
            }
        }
        searchResultAnnotationsToken = vm.$searchResultAnnotation.sink { newValue in
            let oldValue = self.vm.searchResultAnnotation
            DispatchQueue.main.async {
                if let oldValue = oldValue {
                    self.map.removeAnnotation(oldValue)
                }
                if let newValue = newValue {
                    self.map.addAnnotation(newValue)
                }
            }
        }
        selectedAnnotationsToken = vm.$selectedAnnotation.debounce(for: .seconds(0.1), scheduler: RunLoop.main).sink { newValue in
            DispatchQueue.main.async {
                if newValue != nil {
                    self.panelContentVC.show(self.placeVC, sender: nil)
                } else {
                    self.panelContentVC.hideAll()
                }
                
                if let newValue = newValue {
                    self.map.selectAnnotation(newValue, animated: true)
                } else {
                    self.map.deselectAnnotation(self.map.selectedAnnotations.first, animated: true)
                }
            }
        }
        boundingRegionToken = vm.$boundingRegion.sink {
            if $0 != nil {
                self.map.region = $0!
                print("map.region \(self.map.region)")
            }
        }
        
        
        map.addAnnotations(vm.annotations)
        map.register(MKAnnotationView.self, forAnnotationViewWithReuseIdentifier: Self.annotationViewIdentifier)
        map.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: Self.markAnnotationViewIdentifier)
        map.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: Self.pinAnnotationViewIdentifier)
        
        
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
        
        searchResultAnnotationsToken?.cancel()
        searchResultAnnotationsToken = nil
        
        boundingRegionToken?.cancel()
        boundingRegionToken = nil
        
        selectedAnnotationsToken?.cancel()
        selectedAnnotationsToken = nil
    }
}

// MARK: PlaceVCDelegate
extension MapVC: PlaceVCDelegate {
    func placeWillDisappear(_ placeVC: PlaceVC) {
        vm.deSelectAnnotation()
    }
    
    func placeVCShouldStartFeedback(_ placeVC: PlaceVC) {
        FeedbackVM(placeId: self.vm.selectedPlaceId!) { vm in
            DispatchQueue.main.async {
                self.panelContentVC.show(FeedbackVC(feedbackVM: vm), sender: nil)
            }
        }
    }
    
    func placeVCShouldMarkVisited(_ placeVC: PlaceVC) {
        vm.markVisited()
    }
    
    func placeVCShouldDiscoverNext(_ placeVC: PlaceVC) {
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
        //        MapSysEnvironment.shared.userCurrentCoordinate = userLocation.coordinate
    }
    
    static let annotationViewIdentifier = "annotationView"
    static let markAnnotationViewIdentifier = "markAnnotationView"
    static let pinAnnotationViewIdentifier = "markAnnotationView"
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !annotation.isKind(of: MKUserLocation.self) else {
            return nil
        }
        
        if annotation is MapItemAnnotation {
            let view =  mapView.dequeueReusableAnnotationView(withIdentifier: Self.markAnnotationViewIdentifier, for: annotation) as! MKMarkerAnnotationView
            view.displayPriority = .required
            view.canShowCallout = true
            view.animatesWhenAdded = true
            view.isHighlighted = true
            return view
        } else if annotation is SemAnnotation1 {
            let view =  mapView.dequeueReusableAnnotationView(withIdentifier: Self.markAnnotationViewIdentifier, for: annotation) as! MKMarkerAnnotationView
            view.canShowCallout = true
            view.animatesWhenAdded = true
            return view
        } else {
            let view = mapView.dequeueReusableAnnotationView(withIdentifier: Self.annotationViewIdentifier, for: annotation)
            view.canShowCallout = true
            let size = CGSize(width: 10, height: 10)
            view.image = UIGraphicsImageRenderer(size: size).image { context in
                UIImage(systemName:"circle.fill")!.withTintColor(.brown).draw(in:CGRect(origin:.zero, size: size))
            }
            return view
        }
    }
    
    // MARK: Interaction
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard !view.annotation!.isKind(of: MKUserLocation.self) else {
            return
        }
        
        vm.selectAnnotation(view.annotation! as! SemAnnotation)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        guard !view.annotation!.isKind(of: MKUserLocation.self) else {
            return
        }
        
        vm.didDeSelectAnnotation(view.annotation! as! SemAnnotation)
    }
}

// MARK: FloatingPanelControllerDelegate
extension MapVC: FloatingPanelControllerDelegate {
    
}

// MARK: PanelContentDelegate
extension MapVC: PanelContentDelegate {
}
