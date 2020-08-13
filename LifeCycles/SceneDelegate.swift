//
//  SceneDelegate.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/5/18.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import UIKit
import SwiftUI
import CoreData
import CloudKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate, CoreDataAccessor {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        print("lifcycle: \(#function)")
        let window = UIWindow(windowScene: scene as! UIWindowScene)
        self.window = window
        
//        let firstSector = SectorDataLayer.shared.queryByDisplayOrder(0, operator: .equal) ?? Sector(context: appManagedObjectContext)
//        window.rootViewController = FloatContainerVC(rootVC: SemSectorsVC(firstSector: firstSector))
        
        let mapVM = MapVM()
        let mapVC = MapVC(vm: mapVM)
        window.rootViewController = mapVC
        
//        window.rootViewController = TestVC()
        
        window.makeKeyAndVisible()
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        print("lifcycle: \(#function)")
        if AccountLayer.shared.currentUser == nil {
            window!.rootViewController!.present(LoginVC(), animated: true, completion: nil)
        } else {
            NotificationCenter.default.post(name: .signedIn, object: nil)
        }
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        print("lifcycle: \(#function)")
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        
        // Save changes in the application's managed object context when the application transitions to the background.
        CoreDataSpace.shared.saveContext()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
        NotificationCenter.default.removeObserver(self)
    }
}

extension SceneDelegate {
    func windowScene(_ windowScene: UIWindowScene, userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata) {
        let acceptSharesOperation = CKAcceptSharesOperation(shareMetadatas: [cloudKitShareMetadata])
        acceptSharesOperation.acceptSharesCompletionBlock = { error in
            guard error == nil else {
                fatalError("\(error)")
            }
            
            let rootRecordID = cloudKitShareMetadata.rootRecordID
            let op = CKFetchRecordsOperation(recordIDs: [rootRecordID])
            op.fetchRecordsCompletionBlock = {  recordsByRecordID, error in
                guard error == nil, let rootRecord = recordsByRecordID?[rootRecordID] else {
                    fatalError("\(error)")
                }
                DispatchQueue.main.async {
                    let vc = WordVC1(word: CKWordVM(word: rootRecord))
                    (self.window!.rootViewController as! FloatContainerVC).setVC(vc)
                    
                }
            }
            
            CloukitSpace.shared.container.sharedCloudDatabase.add(op)
        }
        
        CloukitSpace.shared.container.add(acceptSharesOperation)
    }
}
