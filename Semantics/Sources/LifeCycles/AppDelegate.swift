import UIKit
import CoreData
import CloudKit
import Foundation
//import Iconic
//import Highcharts
import AuthenticationServices
import Sentry
import Amplify
import AmplifyPlugins

class AppDelegate: UIResponder, UIApplicationDelegate, CoreDataAccessor {
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        SentrySDK.start { options in
            options.dsn = "https://65e39c9216234994b902b4ea809e7dae@o310831.ingest.sentry.io/5449834"
            options.debug = true
        }
        
        try! Amplify.add(plugin: AWSCognitoAuthPlugin())
        try! Amplify.add(plugin: AWSS3StoragePlugin())
        try! Amplify.configure()
        
        RealmSpace.load()
        
        Concept.load()
        
        return true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //        _ = CoreDataSpace.shared
        //        _ = CloukitSpace.shared
        //        FontAwesomeIcon.register()
        //
        //        CloudSync.default.loadLastToken()
        //
        //        //        HIChartView.preload()
        //
        //        NotificationCenter.default.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange), name: .NSManagedObjectContextObjectsDidChange, object: CoreDataSpace.shared.persistentContainer.viewContext)
        //
        //        CKContainer.default().requestApplicationPermission(.userDiscoverability) { status, error in
        ////            guard status == .granted, error == nil else {
        ////                   fatalError("\(error)")
        ////            }
        //        }
        return true
    }
}

extension AppDelegate {
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

//extension AppDelegate {
//    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
//        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
//            guard let url = userActivity.webpageURL else {
//                return false
//            }
//            print("userActivity \(url)")
//            return true
//        }
//        return false
//    }
//}

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
