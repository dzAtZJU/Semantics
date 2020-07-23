//
//  SemOceanVC.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/7/18.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import UIKit
import CoreData

class SemSectorVC: UIPageViewController {
    
    let sector: Sector
    
    init(sector sector_: Sector) {
        sector = sector_
        
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)

        dataSource = self
        
        var firstOceanLayer = OceanLayerDataLayer.shared.queryByProximityEnding(.min, in: sector)
        if firstOceanLayer == nil {
            firstOceanLayer = OceanLayer(context: managedObjectContext, sector: sector, proximity: 0)
        }
        
        setViewControllers([UINavigationController(rootViewController: OceanLayerVC(oceanLayer: firstOceanLayer!))], direction: .forward, animated: false, completion: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange), name: .NSManagedObjectContextObjectsDidChange, object: managedObjectContext)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

extension SemSectorVC: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if viewController is OrganVC {
            return nil
        }
        
        if viewController is BarrierVC {
            let oceanLayer = OceanLayerDataLayer.shared.queryByProximityEnding(.max, in: sector) ?? OceanLayer(context: managedObjectContext, sector: sector, proximity: 0)
            return UINavigationController(rootViewController: OceanLayerVC(oceanLayer: oceanLayer))
        }

        let origin = (viewController.children.first! as! OceanLayerVC)
        if let lesser = OceanLayerDataLayer.shared.queryByProximity(origin.oceanLayer.proximity, operator: .less, in: sector) {
            return UINavigationController(rootViewController: OceanLayerVC(oceanLayer: lesser))
        }
        
        return OrganVC()
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if viewController is BarrierVC {
            return nil
        }
        
        if viewController is OrganVC {
            let oceanLayer = OceanLayerDataLayer.shared.queryByProximityEnding(.min, in: sector) ?? OceanLayer(context: managedObjectContext, sector: sector, proximity: 0)
            return UINavigationController(rootViewController: OceanLayerVC(oceanLayer: oceanLayer))
        }

        let origin = (viewController.children.first! as! OceanLayerVC)
        if let larger = OceanLayerDataLayer.shared.queryByProximity(origin.oceanLayer.proximity, operator: .larger, in: sector) {
            return UINavigationController(rootViewController: OceanLayerVC(oceanLayer: larger))
        }

        return BarrierVC()
    }
}

// Notification
extension SemSectorVC {
    @objc func managedObjectContextObjectsDidChange(notification: NSNotification) {
        guard let semSetsVC = viewControllers!.first!.children.first as? OceanLayerVC else {
            return
        }
        
        if let deleted = notification.userInfo?[NSDeletedObjectsKey] as? Set<NSManagedObject>, deleted.count > 0, deleted.contains(semSetsVC.oceanLayer) {
            
            if let prev = pageViewController(self, viewControllerBefore: viewControllers!.first!) {
                setViewControllers([prev], direction: .reverse, animated: true, completion: nil)
                return
            }
            
            let next = pageViewController(self, viewControllerAfter: viewControllers!.first!)!
            setViewControllers([next], direction: .forward, animated: true, completion: nil)
        } else {
            setViewControllers(viewControllers!, direction: .reverse, animated: false, completion: nil)
        }
    }
}
