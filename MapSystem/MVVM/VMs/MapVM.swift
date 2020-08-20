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

class MapVM {
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(signdeInReceived), name: .signedIn, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(searchFinished), name: .searchFinished ,object: nil)
    }
    
    lazy var conditionsVM: ConditionsVM = {
        var tmp: ConditionsVM!
        RealmSpace.shared.queue.sync {
            let realm = RealmSpace.shared.newRealm(RealmSpace.partitionValue)
            let conditions =  realm.objects(Condition.self)
            tmp = ConditionsVM(conditions: conditions)
            tmp.delegate = self
            tmp.iterationUpdater = {
                switch $0 {
                case .none:
                    print("iterationUpdater none")
                case .ok(var places):
                    RealmSpace.shared.queue.async {
                        self.annotations = SemWorldDataLayer(realm: RealmSpace.shared.newRealm(RealmSpace.partitionValue)).queryPlaces(_ids: Array(places.placeId2Conditions.keys)).map(SemAnnotation1.init)
                    }
                }
            }
        }
        return tmp
    }()
    
    lazy var placeVM: PlaceVM = {
        let tmp = PlaceVM(parent: self)
        return tmp
    }()
    
    @Published private(set) var selectedAnnotation: SemAnnotation?
    
    @Published private(set) var selectedPlaceState: PlaceState?
    
    @Published private(set) var annotations = [MKAnnotation]()
    
    @Published var searchResultAnnotation: MKAnnotation?
    
    @Published private(set) var boundingRegion: MKCoordinateRegion?
    
    var signedIn: (() -> Void)?
    
    private lazy var locationManager: CLLocationManager = {
        let tmp = CLLocationManager()
        return tmp
    }()
    
    func requestLocationAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func setAnnotation(_ value: SemAnnotation?, to isSelected: Bool) {
        guard let value = value else {
            if selectedAnnotation != nil {
                selectedAnnotation = nil
            }
            return
        }
        
        if !isSelected {
            guard selectedAnnotation === value else {
                return
            }
        }
        
        selectedAnnotation = isSelected ? value : nil
        if let placeId = value.placeId {
            RealmSpace.shared.async {
                if let placeStory = SemWorldDataLayer(partitionValue: RealmSpace.partitionValue).queryPlaceStory(placeId: placeId) {
                    self.selectedPlaceState =  PlaceState(rawValue: placeStory.state)
                } else {
                    self.selectedPlaceState = .neverBeen
                }
            }
        } else {
            selectedPlaceState = .neverBeen
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: Places
extension MapVM {
    func loadVisitedPlaces() {
        RealmSpace.shared.async {
            self.annotations = SemWorldDataLayer(partitionValue: RealmSpace.partitionValue).queryVisitedPlaces().map(SemAnnotation.init)
        }
    }
    
    func markVisited() {
        let uniquePlace = UniquePlace(annotation: self.selectedAnnotation!)
        RealmSpace.shared.async {
            SemWorldDataLayer(partitionValue: RealmSpace.partitionValue).markVisited(uniquePlace: uniquePlace) { place in
                let newAnnotation = SemAnnotation(place: place)
                self.annotations.append(newAnnotation)
                self.searchResultAnnotation = nil
                self.setAnnotation(newAnnotation, to: true)
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
        searchResultAnnotation = response.mapItems.map(MapItemAnnotation.init).first!
        boundingRegion = response.boundingRegion
        setAnnotation(searchResultAnnotation as! SemAnnotation, to: true)
        let sameAnnotation = annotations.first {
            $0.coordinate == searchResultAnnotation!.coordinate && $0.title == searchResultAnnotation!.title
        }
        if let sameAnnotation = sameAnnotation {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.searchResultAnnotation = nil
                self.setAnnotation(sameAnnotation as! SemAnnotation, to: true)
            }
        }
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
