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
    var thePlaceId: String?
    
    var panelContentVMDelegate: PanelContentVMDelegate!
    
    private var placeStoryToken: NSKeyValueObservation?
    
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
        thePlaceId = placeStory_.placeID
        placeState = PlaceState(rawValue: placeStory_.state)!
        perspectivesToken = placeStory_.perspectiveID_List.observe {
            switch $0 {
            case .initial(let perspectives_):
                fallthrough
            case .update(let perspectives_, _, _, _):
                self.perspectives = perspectives_.map { $0 }
            case .error(let error):
                fatalError("\(error)")
            }
        }
        placeStoryToken = placeStory_.observe(\.state, options: [.new], changeHandler: { (placeStory, change) in
            self.placeState = PlaceState(rawValue: change.newValue!)!
        })
    }
    
    private init() {
        placeState = .neverBeen
    }
    
    var perspectiveChoice_List: [PerspectiveChoice] {
        var perspectiveChoice_List: [PerspectiveChoice] = []
        if let placePerspectives = perspectives {
            let privatePerspectives = SemWorldDataLayer(realm: RealmSpace.main.realm(RealmSpace.queryCurrentUserID()!)).queryPrivatePerspectives()
            perspectiveChoice_List = privatePerspectives.map {
                PerspectiveChoice(perspective: $0, isChosen: placePerspectives.contains($0))
            }
        }
        return perspectiveChoice_List
    }
    
    deinit {
        placeStoryToken?.invalidate()
        perspectivesToken?.invalidate()
    }
}

extension PlaceVM: PerspectivesVCDelegate {
    func perspectivesVCDidFinishChoose(_ perspectivesVC: PerspectivesVC, perspectiveChoice_List: [PerspectiveChoice]) {
        guard let perspectives = perspectives else {
            fatalError()
        }
        
        let publicLayer = SemWorldDataLayer(realm: RealmSpace.main.realm(RealmSpace.partitionValue))
        let privateLayer = SemWorldDataLayer2(layer1: SemWorldDataLayer(realm: RealmSpace.main.realm(RealmSpace.queryCurrentUserID()!)))
        perspectiveChoice_List.forEach {
            if $0.isChosen && !perspectives.contains($0.perspective) {
                publicLayer.createCondition_IfNone(id: $0.perspective)
                privateLayer.projectPerspective($0.perspective, on: thePlaceId!)
            } else if !$0.isChosen && perspectives.contains($0.perspective) {
                privateLayer.withdrawPerspective($0.perspective, from: thePlaceId!)
            }
        }
    }
}
