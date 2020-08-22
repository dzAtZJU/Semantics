//
//  DiscoveredPlaceVC.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/8/22.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import UIKit

class DiscoveredPlaceVC: UIViewController, PanelContent {
    var panelContentDelegate: PanelContentDelegate?
    
    let showBackBtn = true
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .yellow
    }
}
