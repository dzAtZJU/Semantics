//
//  MapView.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/5/20.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    let location: CLLocationCoordinate2D
    
    func makeUIView(context: Context) -> MKMapView {
        return MKMapView(frame: .zero)
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {        let span = MKCoordinateSpan(latitudeDelta: 2.0, longitudeDelta: 2.0)
        let region = MKCoordinateRegion(center: location, span: span)
        uiView.setRegion(region, animated: true)
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(location: landmarkData[0].locationCoordinate)
    }
}
