//
//  OceanLayer+.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/7/20.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import CoreData

extension OceanLayer {
    convenience init(context: NSManagedObjectContext, sector sector_: Sector, proximity proximity_: Int16) {
        self.init(context: context)
        sector = sector_
        proximity = proximity_
    }
}
