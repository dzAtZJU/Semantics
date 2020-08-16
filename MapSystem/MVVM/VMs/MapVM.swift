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
import RealmSwift

class MapVM {
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(signdeInReceived), name: .signedIn, object: nil)
    }
    
    lazy var conditionsVM: ConditionsVM = {
        var tmp: ConditionsVM!
        RealmSpace.shared.queue.sync {
            let realm = RealmSpace.shared.newRealm("Public")
            let conditions =  realm.objects(Condition.self)
            tmp = ConditionsVM(conditions: conditions)
            tmp.delegate = self
            tmp.iterationUpdater = {
                switch $0 {
                case .none:
                    print("iterationUpdater none")
                case .ok(var places):
                    RealmSpace.shared.queue.async {
                        self.annotations = SemWorldDataLayer(realm: RealmSpace.shared.newRealm("Public")).queryPlaces(_ids: Array(places.placeId2Conditions.keys)).map(SemAnnotation1.init)
                    }
                }
            }
        }
        return tmp
    }()
    
    private var selectedAnnotation: SemAnnotation?
    
    @Published private(set) var annotations = [MKAnnotation]()
    
    @Published private(set) var boundingRegion: MKCoordinateRegion?
    
    var signedIn: (() -> Void)?
    
    private lazy var locationManager: CLLocationManager = {
        let tmp = CLLocationManager()
        return tmp
    }()
    
    func requestLocationAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func loadVisitedPlaces() {
        RealmSpace.shared.async {
            self.annotations = SemWorldDataLayer(partitionValue: "Public").queryAllPlaces().map(SemAnnotation.init)
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
    
    func setSelectedAnnotation(_ value: SemAnnotation?) {
        selectedAnnotation = value
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension MapVM {
    @objc private func signdeInReceived(notification: Notification) {
        loadVisitedPlaces()
        signedIn?()
    }
}

extension MapVM: ConditionsVMDelegate {
    var selectedPlaceId: ObjectId? {
        selectedAnnotation?.placeId
    }
}
