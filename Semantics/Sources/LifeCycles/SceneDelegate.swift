import UIKit
import SwiftUI
import Swinject
import CoreData
import CloudKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate, CoreDataAccessor {
    var window: UIWindow?
    
    private let container = Container() { container in
        container.register(TileMapVC.self) { r in
            let vc = TileMapVC()
            return vc
        }
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let mapVC = UINavigationController(rootViewController: MapVC(vm: MapVM(circleOfTrust: .public)))
        mapVC.navigationBar.isTranslucent = true
        let wishVC = UINavigationController(rootViewController: MapVC(vm: PartnersMapVM()))
        let tabVC = UITabBarController()
        tabVC.setViewControllers([mapVC, wishVC, container.resolve(TileMapVC.self)!], animated: false)
        
        let window = UIWindow(windowScene: scene as! UIWindowScene)
        self.window = window
        window.rootViewController = tabVC
        window.makeKeyAndVisible()
        
        if let userActivity = connectionOptions.userActivities.first {
            checkUserActivity(userActivity)
        }
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        checkUserActivity(userActivity)
    }
    
    private func checkUserActivity(_ userActivity: NSUserActivity) {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb, let incomingURL = userActivity.webpageURL, let components = NSURLComponents(url: incomingURL, resolvingAgainstBaseURL: true) {
            let path = components.path!
            let inviter = String(path.split(separator: "/")[1])
            print("[UniversalLink] inviter: \(inviter)")
            (self.window?.rootViewController as! UITabBarController).selectedIndex = 1
            NotificationCenter.default.post(name: NSNotification.Name.inviteReceived, object: inviter)
        }
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        //        let user = RealmSpace.queryCurrentUser()
        //        if user == nil {
        //            DispatchQueue.main.async {
        //                self.window!.rootViewController!.present(LoginVC(), animated: true, completion: nil)
        //            }
        //        } else {
        //            NotificationCenter.default.post(name: .signedIn, object: nil)
        //        }
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        
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
