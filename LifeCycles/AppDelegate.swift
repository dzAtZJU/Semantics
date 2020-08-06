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
class AppDelegate: UIResponder, UIApplicationDelegate, CoreDataAccessor {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        CoreDataSpace.shared
        CloukitSpace.shared
        FontAwesomeIcon.register()
        
        CloudSync.default.loadLastToken()
        
        //        HIChartView.preload()
        
        NotificationCenter.default.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange), name: .NSManagedObjectContextObjectsDidChange, object: CoreDataSpace.shared.persistentContainer.viewContext)
        
        CKContainer.default().requestApplicationPermission(.userDiscoverability) { status, error in
//            guard status == .granted, error == nil else {
//                   fatalError("\(error)")
//            }
        }
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
                        CoreDataSpace.shared.persistentContainer.viewContext.delete(oceanLayer)
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
