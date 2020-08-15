//
//  SemAnnotation.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/8/7.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//
import MapKit
import RealmSwift

class SemAnnotation: MKPointAnnotation {
    var placeId: ObjectId?
    init(place: Place) {
        placeId = place._id
        super.init()
        title = place.title
        coordinate = CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)
    }
}

class SemAnnotation1: SemAnnotation {
}
