//
//  PanelContentVM.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/8/29.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//
import RealmSwift

protocol PanelContentVM {
    var panelContentVMDelegate: PanelContentVMDelegate! { get set }
    
    var thePlaceId: String? {
        get
    }
}

protocol PanelContentVMDelegate {
    var mapVM: MapVM {
        get
    }
}
