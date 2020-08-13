//
//  SectorDataLayer.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/7/18.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import CoreData
import Foundation

class SectorDataLayer: CoreDataAccessor {
    static let shared = SectorDataLayer()
    
    func queryByDisplayOrder(_ value: Int, operator: Operator) -> Sector? {
        let query: NSFetchRequest<Sector> = Sector.fetchRequest()
        
        let format = "displayOrder \(`operator`.rawValue) %@ && displayOrder != %@"
        query.predicate = NSPredicate(format: format, NSNumber(integerLiteral: value), NSNumber(integerLiteral: Sector.organDisplayOrder))
        let ascending = `operator` == .larger
        query.sortDescriptors = [NSSortDescriptor(key: "displayOrder", ascending: ascending)]
        query.fetchLimit = 1
        do {
            return try appManagedObjectContext.fetch(query).first
        } catch {
            fatalError("\(error)")
        }
    }
    
    func queryDisplayOrderEnding(_ ending: Ending) -> Int16 {
        precondition(ending == .max)
        let query: NSFetchRequest<Sector> = Sector.fetchRequest()
        query.predicate = NSPredicate(format: "displayOrder != %@", NSNumber(integerLiteral: Sector.organDisplayOrder))
        do {
            return try Int16(appManagedObjectContext.count(for: query)) - 1
        } catch {
            fatalError("\(error)")
        }
    }
    
    func queryByDisplayOrderEnding(_ ending: Ending) -> Sector? {
        let query: NSFetchRequest<Sector> = Sector.fetchRequest()
        query.predicate = NSPredicate(format: "displayOrder != %@", NSNumber(integerLiteral: Sector.organDisplayOrder))
        query.sortDescriptors = [NSSortDescriptor(key: "displayOrder", ascending: ending == .min)]
        query.fetchLimit = 1
        do {
            return try appManagedObjectContext.fetch(query).first
        } catch {
            fatalError("\(error)")
        }
    }
    
    func queryOrganSector() -> Sector {
        let query: NSFetchRequest<Sector> = Sector.fetchRequest()
        query.predicate = NSPredicate(format: "displayOrder == %@", NSNumber(integerLiteral: Sector.organDisplayOrder))
        do {
            guard let r = try appManagedObjectContext.fetch(query).first else {
                let newR = Sector(context: appManagedObjectContext)
                newR.displayOrder = Int16(Sector.organDisplayOrder)
                let newLayer = OceanLayer(context: appManagedObjectContext)
                newLayer.sector = newR
                let eye = Word(context: appManagedObjectContext)
                eye.name = "Eye"
                eye.oceanLayer = newLayer
                CoreDataSpace.shared.saveContext()
                return newR
            }
            return r
        } catch {
            fatalError("\(error)")
        }
    }
}
