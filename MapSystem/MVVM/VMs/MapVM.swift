//
//  MapVM.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/8/13.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation

class MapVM {
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(signdeInReceived), name: .signedIn, object: nil)
    }
    
    let conditionsVM = ConditionsVM()
    
    var selectedAnnotation: MKAnnotation?
    
    @Published private(set) var annotations = [MKAnnotation]()
    
    @Published private(set) var boundingRegion: MKCoordinateRegion?
    
    private lazy var locationManager: CLLocationManager = {
        let tmp = CLLocationManager()
        return tmp
    }()
    
    func requestLocationAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func loadPlaces() {
        annotations = SemWorldDataLayer.shared.queryPlaces().map { place in
            let tmp = MKPointAnnotation()
            tmp.title = place.title
            tmp.coordinate = CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)
            return tmp
        }
    }
    
    func setPlaces(_ items: [MKMapItem], boundingRegion boundingRegion_: MKCoordinateRegion) {
        annotations = items.map {
            let tmp = MKPointAnnotation()
            tmp.coordinate = $0.placemark.coordinate
            tmp.title = $0.name
            return tmp
        }
        boundingRegion = boundingRegion_
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension MapVM {
    @objc private func signdeInReceived(notification: Notification) {
        SemWorldDataLayer.shared.createMockData()
        loadPlaces()
    }
}
