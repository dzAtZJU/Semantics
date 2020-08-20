//
//  CLLocationCoordinate2D+.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/8/19.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import CoreLocation

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
