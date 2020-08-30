//
//  PlaceVM.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/8/20.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import Foundation
import Combine
import RealmSwift

class PlaceVM: PanelContentVM {
    var thePlaceId: ObjectId? {
        nil
    }
    var panelContentVMDelegate: PanelContentVMDelegate!
    
    static func new(placeId: ObjectId?, completion: @escaping (PlaceVM) -> Void) {
        if let placeId = placeId {
            RealmSpace.shared.async {
                let placeStory = SemWorldDataLayer(realm: RealmSpace.shared.realm(partitionValue: RealmSpace.partitionValue)).queryPlaceStory(placeId: placeId)
                let vm = PlaceVM(placeStory: placeStory)
                completion(vm)
            }
        } else {
            completion(PlaceVM())
        }
    }
    
    private var placeStoryToken: NotificationToken?
    @Published private(set) var placeState: PlaceState
    private init(placeStory: PlaceStory) {
        placeState = PlaceState(rawValue: placeStory.state)!
        placeStoryToken = placeStory.observe({ change in
            switch change {
            case .change(_, let properties):
                if let stateChange = try! properties.first(where: { (property: PropertyChange) throws -> Bool in
                    property.name == #keyPath(PlaceStory.state)
                }) {
                    self.placeState = PlaceState(rawValue: stateChange.newValue as! Int)!
                }
            case .deleted:
                fatalError("not implemented")
            case .error(let error):
                fatalError(error.debugDescription)
            }
        })
    }
    
    private init() {
        placeState = .neverBeen
    }
    
    deinit {
        placeStoryToken?.invalidate()
    }
}
