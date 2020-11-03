//
//  InfoSpace.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/10/10.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import MapKit
import CoreLocation

extension MKCoordinateRegion {
    var size: CGSize {
        let span = self.span
        let center = self.center
        
        let loc1 = CLLocation(latitude: center.latitude - span.latitudeDelta * 0.5, longitude: center.longitude)
        let loc2 = CLLocation(latitude: center.latitude + span.latitudeDelta * 0.5, longitude: center.longitude)
        let loc3 = CLLocation(latitude: center.latitude, longitude: center.longitude - span.longitudeDelta * 0.5)
        let loc4 = CLLocation(latitude: center.latitude, longitude: center.longitude + span.longitudeDelta * 0.5)
        
        let metersInLatitude = loc1.distance(from: loc2)
        let metersInLongitude = loc3.distance(from: loc4)
        return CGSize(width: metersInLongitude, height: metersInLatitude)
    }
}
