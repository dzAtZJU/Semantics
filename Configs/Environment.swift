//
//  Environment.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/9/28.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//
import Foundation

enum Environment: String {
    case Dev = "Dev"
    case Prod = "Prod"

    static var current: Environment {
        let configuration = Bundle.main.object(forInfoDictionaryKey: "Configuration") as! String
        
        if configuration.contains("Dev"){
            return Environment.Dev
        } else if configuration.contains("Prod") {
            return Environment.Prod
        } else {
            fatalError("Configuration should either be dev or prod")
        }
    }
    
    var realmApp: String {
        switch self {
        case .Dev: return "semantics_dev-wvrwg"
        case .Prod: return "semantics-tonbj"
        }
    }
}
