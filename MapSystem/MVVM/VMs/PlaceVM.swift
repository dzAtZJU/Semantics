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
    var thePlaceId: String? {
        nil
    }
    var panelContentVMDelegate: PanelContentVMDelegate!
    
    private var placeStoryToken: NotificationToken?
    
    private var perspectivesToken: NotificationToken?
    
    @Published private(set) var perspectives: [String]?
    
    @Published private(set) var placeState: PlaceState
    
    static func new(placeID: String?, completion: @escaping (PlaceVM) -> Void) {
        if let placeId = placeID {
            RealmSpace.shared.async {
                let placeStory = SemWorldDataLayer(realm: RealmSpace.shared.realm(RealmSpace.queryCurrentUserID()!)).loadPlaceStory(placeID: placeId)
                let vm = PlaceVM(placeStory: placeStory!)
                completion(vm)
            }
        } else {
            // This place hasn't been visited by anyone, thus its not in realm
            completion(PlaceVM())
        }
    }
    
    private init(placeStory placeStory_: PlaceStory) {
        placeState = PlaceState(rawValue: placeStory_.state)!
        perspectivesToken = placeStory_.perspectives.observe {
            switch $0 {
            case .initial(let perspectives_):
                fallthrough
            case .update(let perspectives_, _, _, _):
                self.perspectives = perspectives_.map { $0 }
            case .error(let error):
                fatalError("\(error)")
            }
        }
        placeStoryToken = placeStory_.observe({ change in
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
        perspectivesToken?.invalidate()
    }
}
