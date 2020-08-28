//
//  DiscoverdResultVM.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/8/29.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//
import RealmSwift

struct DiscoverdResultVM: PanelContentVM {
    let result: RealmSpace.SearchNextResult
    init(result result_: RealmSpace.SearchNextResult) {
        result = result_
    }
    var count: Int {
        result.places.count
    }
    
    var panelContentVMDelegate: PanelContentVMDelegate!
    
    let thePlaceId: ObjectId? = nil
}
