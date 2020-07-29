//
//  AppDelegate.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/5/18.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import UIKit
import CoreData
import CloudKit
import Foundation
import Iconic
import Highcharts

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FontAwesomeIcon.register()
        
        //        HIChartView.preload()
        
        NotificationCenter.default.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange), name: .NSManagedObjectContextObjectsDidChange, object: persistentContainer.viewContext)
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentCloudKitContainer = {
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
    
    // MARK: CloudKit
    
    //    lazy var publicContainer = CKContainer(identifier: "iCloud.ind.paper.semantics")
    
}

// Notification
extension AppDelegate {
    @objc func managedObjectContextObjectsDidChange(notification: NSNotification) {
        if let updates = notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject>, updates.count > 0 {
            updates.forEach {
                if let oceanLayer = $0 as? OceanLayer {
                    guard oceanLayer.changedValuesForCurrentEvent()["words"] != nil else {
                        return
                    }
                    if oceanLayer.words == nil || oceanLayer.words!.count == 0 {
                        persistentContainer.viewContext.delete(oceanLayer)
                        if let oceanLayers = (oceanLayer.sector!.oceanLayers as? Set<OceanLayer>)?.filter({
                            !$0.isDeleted
                        }) {
                            for (i, l) in oceanLayers.sorted(by: \.proximity).enumerated() {
                                l.proximity = Int16(i)
                            }
                        }
                    }
                }
            }
        }
    }
}
