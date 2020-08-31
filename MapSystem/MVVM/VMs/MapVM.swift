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
    case onlyMap
}

protocol MapVMAnnotationsModel {
    func addAnnotations(_: [SemAnnotation])
           
    func removeAnnotations(_: [SemAnnotation])
    
    var annotations: [SemAnnotation] {
        get
    }
}

class MapVM {
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(signdeInReceived), name: .signedIn, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(searchFinished), name: .searchFinished ,object: nil)
    }
    
    @Published private(set) var selectedAnnotationEvent: (SemAnnotation?, EventSource) = (nil, .fromModel)
    var selectedAnnotationEventLock = false
    
    var annotationsModel: MapVMAnnotationsModel!
    
    private var selectedAnnotation: SemAnnotation? {
        selectedAnnotationEvent.0
    }
    
    var selectedPlaceId: ObjectId? {
        selectedAnnotation?.placeId
    }
    
    @Published private(set) var boundingRegion: MKCoordinateRegion?
    
    var signedIn: (() -> Void)?
    
    private lazy var locationManager: CLLocationManager = {
        let tmp = CLLocationManager()
        return tmp
    }()
    
    func requestLocationAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func setSelectedAnnotationEvent(_ event: (SemAnnotation?, EventSource)) {
        selectedAnnotationEvent = event
    }
    
    func appendAnnotations(_ values: [SemAnnotation]) {
        annotationsModel.addAnnotations(values)
    }
    
    func removeAnnotations(type: AnnotationType) {
        let annos = annotationsModel.annotations.filter {
            $0.type == type
        }
        annotationsModel.removeAnnotations(annos)
    }
    
    func annotion(filter: ((SemAnnotation) -> Bool)? = nil) -> [SemAnnotation] {
        guard let filter = filter else {
            return []
        }
        return annotationsModel.annotations.filter(filter)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    var discoverNextVM: DiscoverNextVM {
        var tmp: DiscoverNextVM!
        RealmSpace.shared.queue.sync {
            let realm = RealmSpace.shared.realm(partitionValue: RealmSpace.partitionValue)
            let conditions =  realm.objects(Condition.self)
            tmp = DiscoverNextVM(placeId: selectedAnnotation!.placeId!, conditions: conditions)
            tmp.panelContentVMDelegate = self
        }
        return tmp
    }
}

// MARK: Places
extension MapVM {
    func loadVisitedPlaces() {
        RealmSpace.shared.async {
            RealmSpace.shared.realm(partitionValue: RealmSpace.partitionValue) {
                let annos = try! SemWorldDataLayer(realm: $0).queryVisitedPlaces().map { place throws in
                    SemAnnotation(place: place, type: .visited)
                }
                    
                DispatchQueue.main.async {
                    self.appendAnnotations(annos)
                }
            }
        }
    }
    
    func markVisited() {
        let uniquePlace = UniquePlace(annotation: self.selectedAnnotation!)
        RealmSpace.shared.async {
            SemWorldDataLayer(realm: RealmSpace.shared.realm(partitionValue: RealmSpace.partitionValue)).markVisited(uniquePlace: uniquePlace) { place in
                DispatchQueue.main.async {
                    self.setSelectedAnnotationEvent((nil, .fromModel))
                    let newAnnotation = SemAnnotation(place: place, type: .visited)
                    self.appendAnnotations([newAnnotation])
                    self.setSelectedAnnotationEvent((newAnnotation, .fromModel))
                }
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
        appendAnnotations([newAnno])
        boundingRegion = response.boundingRegion
        selectedAnnotationEvent = (newAnno, .fromModel)
    }
}

extension MapVM: PanelContentVMDelegate {
    var mapVM: MapVM {
        self
    }
}
