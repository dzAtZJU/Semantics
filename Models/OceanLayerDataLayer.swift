//
//  OceanLayerDataLayer.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/7/18.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import CoreData

struct OceanLayerDataLayer: CoreDataAccessor {
    static let shared = OceanLayerDataLayer()
    
    func queryByProximity(_ value: Int16, operator: Operator, in sector: Sector) -> OceanLayer? {
        let format = "proximity \(`operator`.rawValue) %@"
        let predicate = NSPredicate(format: format, NSNumber(integerLiteral: Int(value)))
        let filtered = sector.oceanLayers?.filtered(using: predicate) as? Set<OceanLayer>
        let sorted = filtered?.sorted(by: \.proximity)
        if `operator` == .less {
            return sorted?.last
        } else {
            return sorted?.first
        }
    }
    
    func queryByProximityEnding(_ ending: Ending, in sector: Sector) -> OceanLayer? {
        let sorted = (sector.oceanLayers as? Set<OceanLayer>)?.sorted(by: \.proximity)
        if ending == .max {
            return sorted?.last
        } else {
            return sorted?.first
        }
    }
}
