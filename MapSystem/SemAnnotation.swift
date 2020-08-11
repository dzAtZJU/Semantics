//
//  SemAnnotation.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/8/7.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//
import MapKit

class SemAnnotation: NSObject, MKAnnotation {
    @objc dynamic var coordinate = CLLocationCoordinate2D(latitude: 37.779_379, longitude: -122.418_433)
    
    var title: String? = "Tims-Shangbing"
    
    var subTitle: String? = "coffee"
}
