//
//  PlaceVM.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/8/20.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import Foundation
import Combine

class PlaceVM {
    init(parent: MapVM) {
        selectedPlaceStateToken = parent.$selectedPlaceState.compactMap { $0 }.assign(to: \.placeState, on: self)
    }
    
    private var selectedPlaceStateToken: AnyCancellable?
    
    @Published private(set) var placeState = PlaceState.neverBeen
    
    deinit {
        selectedPlaceStateToken?.cancel()
        selectedPlaceStateToken = nil
    }
}
