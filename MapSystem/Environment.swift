//
//  Environment.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/8/16.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import CoreLocation
import Combine
import MapKit

class MapSysEnvironment {
    static let shared = MapSysEnvironment()
    
    private init() {}
    
    @Published var userCurrentCoordinate: CLLocationCoordinate2D?
    
    var searchRegion: MKCoordinateRegion? {
        guard let userCurrentCoordinate = userCurrentCoordinate else {
            return nil
        }
        
        return MKCoordinateRegion(center: userCurrentCoordinate, latitudinalMeters: 30_000, longitudinalMeters: 30_000)
    }
}
