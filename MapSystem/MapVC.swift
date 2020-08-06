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

class MapVM: NSObject {
    private lazy var locationManager: CLLocationManager = {
        let tmp = CLLocationManager()
        tmp.delegate = self
        return tmp
    }()
    
    @Published var currentLocationCoordinate2D = CLLocationCoordinate2D()
    
    func requestLocationAuthorization() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func stopLocationService() {
        locationManager.stopUpdatingLocation()
    }
    
}

extension MapVM: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocationCoordinate2D = locations.first!.coordinate
        manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if (error as! CLError).code == .denied {
            manager.stopUpdatingLocation()
        }
    }
}

class MapVC: UIViewController {
    
    private lazy var map: MKMapView = {
        let tmp = MKMapView()
        tmp.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tmp.region = MKCoordinateRegion(center: CLLocationCoordinate2D(), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        return tmp
    }()
    
    private let vm: MapVM
    private var locationSubscriber: AnyCancellable?
    
    init(vm vm_: MapVM) {
        vm = vm_
        
        super.init(nibName: nil, bundle: nil)
        locationSubscriber = vm.$currentLocationCoordinate2D.assign(to: \.map.centerCoordinate, on: self)
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
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        map.frame = view.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        vm.requestLocationAuthorization()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        vm.stopLocationService()
    }
}
