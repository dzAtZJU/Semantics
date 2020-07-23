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
        
        let format = "displayOrder \(`operator`.rawValue) %@ && displayOrder != %@"
        query.predicate = NSPredicate(format: format, NSNumber(integerLiteral: value), NSNumber(integerLiteral: Sector.organDisplayOrder))
        let ascending = `operator` == .larger
        query.sortDescriptors = [NSSortDescriptor(key: "displayOrder", ascending: ascending)]
        query.fetchLimit = 1
        do {
            return try managedObjectContext.fetch(query).first
        } catch {
            fatalError("\(error)")
        }
    }
    
    func queryDisplayOrderEnding(_ ending: Ending) -> Int16 {
        precondition(ending == .max)
        let query: NSFetchRequest<Sector> = Sector.fetchRequest()
        query.predicate = NSPredicate(format: "displayOrder != %@", NSNumber(integerLiteral: Sector.organDisplayOrder))
        do {
            return try Int16(managedObjectContext.count(for: query)) - 1
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
            return try managedObjectContext.fetch(query).first
        } catch {
            fatalError("\(error)")
        }
    }
    
    func queryOrganOceanLayer() -> Sector {
        let query: NSFetchRequest<Sector> = Sector.fetchRequest()
        query.predicate = NSPredicate(format: "displayOrder == %@", NSNumber(integerLiteral: Sector.organDisplayOrder))
        do {
            guard let r = try managedObjectContext.fetch(query).first else {
                let newR = Sector(context: managedObjectContext)
                newR.displayOrder = Int16(Sector.organDisplayOrder)
                let newLayer = OceanLayer(context: managedObjectContext)
                newLayer.sector = newR
                let eye = Word(context: managedObjectContext)
                eye.name = "Eye"
                eye.oceanLayer = newLayer
                appDelegate.saveContext()
                return newR
            }
            return r
        } catch {
            fatalError("\(error)")
        }
    }
}
