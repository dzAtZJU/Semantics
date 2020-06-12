//
//  SemContentFilterVC.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/6/11.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import UIKit
import NetworkExtension

class SemContentFilterVC: UIViewController {
    override func viewDidLoad() {
        if NEFilterManager.shared().providerConfiguration == nil {
            let config = NEFilterProviderConfiguration()
            config.filterSockets = true
            config.filterBrowsers = true
            NEFilterManager.shared().providerConfiguration = config
        }
        NEFilterManager.shared().isEnabled = true
        NEFilterManager.shared().saveToPreferences { error in
            NSLog("\(error)")
            NEFilterManager.shared().loadFromPreferences { error in
                NSLog("\(error)")
        }
    }
}
}
