//
//  DiscoverdResultVM.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/8/29.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//
import RealmSwift

struct PlaceConditionsVM {
    let conditions: [RealmSpace.SearchNextResult.PlaceConditions.ConditionInfo]
    init(conditions conditions_: [RealmSpace.SearchNextResult.PlaceConditions.ConditionInfo]) {
        conditions = conditions_
    }
    
    var count: Int {
        conditions.count
    }
    
    func title(at: IndexPath) -> String {
        let condition = conditions[at.row]
        return SemWorldDataLayer(realm: RealmSpace.main.realm(partitionValue1: RealmSpace.partitionValue)).queryCondition(_id: condition.id).title + " backed up by \(condition.backers.count) visitors"
    }
    
    func dislike(at: IndexPath, completion: @escaping () -> Void) {
        let info = conditions[at.row]
        let conditionId = info.id
        let inds = info.backers.map(by: \.id)
        RealmSpace.shared.async {
            SemWorldDataLayer(realm: RealmSpace.shared.realm(partitionValue1: RealmSpace.shared.queryCurrentUserID()!)).dislike(inds: inds, forCondition: conditionId)
            completion()
        }
    }
}

class DiscoverdResultVM: PanelContentVM {
    var panelContentVMDelegate: PanelContentVMDelegate!
    var thePlaceId: String?
    
    var placeConditionsVM: PlaceConditionsVM?
    
    let result: RealmSpace.SearchNextResult
    init(result result_: RealmSpace.SearchNextResult) {
        result = result_
    }
    
    func setPlaceId(_ value: String?) {
        thePlaceId = value
        if let value = value {
            let placeConditions = result.places.first { $0.placeId == value }
            placeConditionsVM = PlaceConditionsVM(conditions: placeConditions!.conditions)
        } else {
            placeConditionsVM = nil
        }
    }
    
    func title() -> String {
        "\(result.places.count) places found"
    }
}
