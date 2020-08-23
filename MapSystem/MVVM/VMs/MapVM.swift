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

enum PlaceState: Int {
    case neverBeen = 0
    case visited
    case feedbacked
}

enum EventSource {
    case fromModel
    case fromView
}

class MapVM {
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(signdeInReceived), name: .signedIn, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(searchFinished), name: .searchFinished ,object: nil)
    }
    
    @Published var selectedAnnotationEvent: (SemAnnotation?, EventSource) = (nil, .fromModel)
    
    private var selectedAnnotation: SemAnnotation? {
        selectedAnnotationEvent.0
    }
    
    @Published private(set) var annotations = [SemAnnotation]()
    
    @Published private(set) var boundingRegion: MKCoordinateRegion?
    
    var signedIn: (() -> Void)?
    
    private lazy var locationManager: CLLocationManager = {
        let tmp = CLLocationManager()
        return tmp
    }()
    
    func requestLocationAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    lazy var discoverNextVM: DiscoverNextVM = {
        var tmp: DiscoverNextVM!
        RealmSpace.shared.queue.sync {
            let realm = RealmSpace.shared.newRealm(RealmSpace.partitionValue)
            let conditions =  realm.objects(Condition.self)
            tmp = DiscoverNextVM(conditions: conditions)
            tmp.delegate = self
            tmp.iterationUpdater = {
                switch $0 {
                case .none:
                    print("iterationUpdater none")
                case .ok(var places):
                    RealmSpace.shared.queue.async {
                        self.annotations.removeAll {
                            $0.type == .inDiscovering
                        }
                        self.annotations.append(contentsOf: SemWorldDataLayer(realm: RealmSpace.shared.newRealm(RealmSpace.partitionValue)).queryPlaces(_ids: Array(places.placeId2Conditions.keys)).map({
                            SemAnnotation(place: $0, type: .inDiscovering)
                        }))
                    }
                }
            }
        }
        return tmp
    }()
}

// MARK: Places
extension MapVM {
    func loadVisitedPlaces() {
        RealmSpace.shared.async {
            self.annotations = SemWorldDataLayer(partitionValue: RealmSpace.partitionValue).queryVisitedPlaces().map({
                SemAnnotation(place: $0, type: .visited)
            })
        }
    }
    
    func markVisited() {
        let uniquePlace = UniquePlace(annotation: self.selectedAnnotation!)
        RealmSpace.shared.async {
            SemWorldDataLayer(partitionValue: RealmSpace.partitionValue).markVisited(uniquePlace: uniquePlace) { place in
                let newAnnotation = SemAnnotation(place: place, type: .visited)
                self.annotations.append(newAnnotation)
                self.selectedAnnotationEvent = (newAnnotation, .fromModel)
            }
        }
    }
}

// MARK: Notification
extension MapVM {
    @objc private func signdeInReceived(notification: Notification) {
        loadVisitedPlaces()
        signedIn?()
    }
    @objc private func searchFinished(notification: Notification) {
        let response = notification.object as! MKLocalSearch.Response
        let newAnno = response.mapItems.map({
            SemAnnotation(item: $0, type: .inSearching)
        }).first!
        annotations.append(newAnno)
        boundingRegion = response.boundingRegion
    }
}

// MARK: ConditionsVMDelegate
extension MapVM: ConditionsVMDelegate {
    var selectedPlaceId: ObjectId? {
        selectedAnnotation?.placeId
    }
}

// Mark Visited
// Feedback | Find Next
