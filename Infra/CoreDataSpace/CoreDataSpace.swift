//
//  CoreDataAccessor.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/8/5.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import CoreData
import UIKit

protocol CoreDataAccessor {
    var appDelegate: AppDelegate {
        get
    }
    
    var appManagedObjectContext: NSManagedObjectContext {
        get
    }
    
    var appPersistentContainer: NSPersistentContainer {
        get
    }
}

extension CoreDataAccessor {
    var appDelegate: AppDelegate {
        UIApplication.shared.delegate as! AppDelegate
    }
    
    var appPersistentContainer: NSPersistentContainer {
        CoreDataSpace.shared.persistentContainer
    }
    
    var appManagedObjectContext: NSManagedObjectContext {
        CoreDataSpace.shared.persistentContainer.viewContext
    }
}

class CoreDataSpace {
    
    private init() {}
    
    static let shared = CoreDataSpace()
    
    // MARK: - Core Data stack
    let persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "Semantics")
        
        let storeDescription = container.persistentStoreDescriptions.first
        storeDescription?.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        storeDescription?.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        container.viewContext.mergePolicy = NSMergePolicy.overwrite
        container.viewContext.undoManager = UndoManager()
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
            //            //https://stackoverflow.com/questions/60247412/how-to-make-cloudkit-on-watchos-work-with-nspersistentcloudkitcontainer/63150243#63150243
            //            do {
            //                try container.initializeCloudKitSchema()
            //            } catch {
            //                fatalError("Unresolved error \(error)")
            //            }
            container.viewContext.name = "semantics context"
        })
        
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
