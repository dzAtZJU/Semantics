//
//  FilterControlProvider.swift
//  SemFilterControl
//
//  Created by Zhou Wei Ran on 2020/6/11.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import NetworkExtension

class FilterControlProvider: NEFilterControlProvider {
    
    override init() {
        super.init()
        NSLog("FilterControlProvider inited")
    }
    
    override func startFilter(completionHandler: @escaping (Error?) -> Void) {
        // Add code to initialize the filter
        completionHandler(nil)
    }
    
    override func stopFilter(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        // Add code to clean up filter resources
        completionHandler()
    }
    
    override func handleNewFlow(_ flow: NEFilterFlow, completionHandler: @escaping (NEFilterControlVerdict) -> Void) {
        // Add code to determine if the flow should be dropped or not, downloading new rules if required
        completionHandler(.allow(withUpdateRules: false))
    }
}
