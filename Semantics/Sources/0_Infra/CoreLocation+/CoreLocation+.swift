//
//  CoreLocation+.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2021/1/4.
//  Copyright © 2021 Paper Scratch. All rights reserved.
//

import CoreLocation
import CoreGraphics

extension CLLocationCoordinate2D {
    init(_ cgPoint: CGPoint) {
        self.init(latitude: CLLocationDegrees(cgPoint.y), longitude: CLLocationDegrees(cgPoint.x))
    }
}

extension CGPoint {
    init(_ coordinate2D: CLLocationCoordinate2D) {
        self.init(x: coordinate2D.longitude, y: coordinate2D.latitude)
    }
}
