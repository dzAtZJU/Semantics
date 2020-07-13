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

class SceneDelegate: UIResponder, UIWindowSceneDelegate, CoreDataAccessor {
    var window: UIWindow?
    
    private var pageVC: UIPageViewController!
    
    private let closetVC = SemSetsVC(isArchive: false, proximity: CoreDataLayer1.shared.queryMinProximity())
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        // Get the managed object context from the shared persistent container.
        //        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        // Create the SwiftUI view and set the context as the value for the managedObjectContext environment keyPath.
        // Add `@Environment(\.managedObjectContext)` in the views that will need the context.
        //        let contentView = ContentView().environment(\.managedObjectContext, context)
        //        let contentView = TestView().environment(\.managedObjectContext, context)
        
        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            self.window = window
            
            //            let nav = UINavigationController(rootViewController: SemFoldersVC())
            //            nav.navigationBar.prefersLargeTitles = true
            //            window.rootViewController = nav
            
            //            window.rootViewController = SemSetVC(word: nil, title: nil)
            
            pageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
            pageVC.setViewControllers([UINavigationController(rootViewController: closetVC)], direction: .forward, animated: false, completion: nil)
            pageVC.dataSource = self
            window.rootViewController = pageVC
            
            window.makeKeyAndVisible()
            
            NotificationCenter.default.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange), name: .NSManagedObjectContextObjectsDidChange, object: managedObjectContext)
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
        NotificationCenter.default.removeObserver(self)
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        
        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext.transactionAuthor = "scene enter background"
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
        (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext.transactionAuthor = nil
    }
}

extension SceneDelegate: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let origin = (viewController.children.first! as! SemSetsVC)
        if let lesser = CoreDataLayer1.shared.queryProximity(lessThan: origin.proximity) {
            return UINavigationController(rootViewController: SemSetsVC(isArchive: false, proximity: lesser))
        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let origin = (viewController.children.first! as! SemSetsVC)
        if let larger = CoreDataLayer1.shared.queryProximity(largerThan: origin.proximity) {
            return UINavigationController(rootViewController: SemSetsVC(isArchive: false, proximity: larger))
        }
        
        return nil
    }
}

// Notification
extension SceneDelegate {
    @objc func managedObjectContextObjectsDidChange(notification: NSNotification) {
        let vc = pageVC.viewControllers!.first!.children.first! as! SemSetsVC
        if CoreDataLayer1.shared.queryProximity(equalTo: vc.proximity) == nil {
            let proximity = CoreDataLayer1.shared.queryProximity(lessThan: vc.proximity) ?? CoreDataLayer1.defaultProximity
            pageVC.setViewControllers([UINavigationController(rootViewController: SemSetsVC(isArchive: false, proximity: proximity))], direction: .reverse, animated: true, completion: nil)
        } else {
            pageVC.setViewControllers(pageVC.viewControllers!, direction: .reverse, animated: false, completion: nil)
        }
    }
}
