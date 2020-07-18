//
//  SectorDataLayer.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/7/18.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import CoreData
import Foundation

struct SectorDataLayer: CoreDataAccessor {
    static let shared = SectorDataLayer()
    
    func queryByDisplayOrder(_ value: Int, operator: Operator) -> Sector? {
        let query: NSFetchRequest<Sector> = Sector.fetchRequest()
        
        let format = "displayOrder \(`operator`.rawValue) %@"
        query.predicate = NSPredicate(format: format, NSNumber(integerLiteral: value))
        let ascending = `operator` == .larger
        query.sortDescriptors = [NSSortDescriptor(key: "displayOrder", ascending: ascending)]
        query.fetchLimit = 1
        do {
            return try managedObjectContext.fetch(query).first
        } catch {
            fatalError("\(error)")
        }
    }
    
    func queryByDisplayOrderEnding(_ ending: Ending) -> Int16 {
        precondition(ending == .max)
        
        let query: NSFetchRequest<Sector> = Sector.fetchRequest()
        do {
            return try Int16(managedObjectContext.count(for: query)) - 1
        } catch {
            fatalError("\(error)")
        }
    }
}
