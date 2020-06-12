//
//  FilterDataProvider.swift
//  SemContentFilter
//
//  Created by Zhou Wei Ran on 2020/6/11.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import NetworkExtension

class FilterDataProvider: NEFilterDataProvider {

    override init() {
        super.init()
        NSLog("FilterDataProvider inited")
    }
    
    override func startFilter(completionHandler: @escaping (Error?) -> Void) {
        // Add code to initialize the filter.
        completionHandler(nil)
    }
    
    override func stopFilter(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        // Add code to clean up filter resources.
        completionHandler()
    }
    
    override func handleNewFlow(_ flow: NEFilterFlow) -> NEFilterNewFlowVerdict {
        // Add code to determine if the flow should be dropped or not, downloading new rules if required.
        return .allow()
    }
}
