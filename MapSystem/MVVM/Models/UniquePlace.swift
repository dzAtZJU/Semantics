//
//  UniquePlace.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/8/20.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//
import MapKit

struct UniquePlace {
    let title: String
    let latitude: Double
    let longitude: Double
    
    init(annotation: MKAnnotation) {
        title = annotation.title!!
        latitude = annotation.coordinate.latitude
        longitude = annotation.coordinate.longitude
    }
}
