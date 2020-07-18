//
//  SemOceanVC.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/7/18.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import UIKit

class SemSectorVC: UIPageViewController {
    
    let sector: Sector
    
    init(sector sector_: Sector) {
        sector = sector_
        
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)

        dataSource = self
        
        var firstOceanLayer = OceanLayerDataLayer.shared.queryByProximityEnding(.min, in: sector)
        if firstOceanLayer == nil {
            firstOceanLayer = OceanLayer(context: managedObjectContext)
            firstOceanLayer?.sector = sector
        }
        
        setViewControllers([UINavigationController(rootViewController: SemSetsVC(oceanLayer: firstOceanLayer!))], direction: .forward, animated: false, completion: nil)
        
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
        guard !(viewController is BarrierVC) else {
            let oceanLayer = OceanLayerDataLayer.shared.queryByProximityEnding(.max, in: sector) ?? OceanLayer(context: managedObjectContext)
            return UINavigationController(rootViewController: SemSetsVC(oceanLayer: oceanLayer))
        }

        let origin = (viewController.children.first! as! SemSetsVC)
        if let lesser = OceanLayerDataLayer.shared.queryByProximity(origin.oceanLayer.proximity, operator: .less, in: sector) {
            return UINavigationController(rootViewController: SemSetsVC(oceanLayer: lesser))
        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard !(viewController is BarrierVC) else {
            return nil
        }

        let origin = (viewController.children.first! as! SemSetsVC)
        if let larger = OceanLayerDataLayer.shared.queryByProximity(origin.oceanLayer.proximity, operator: .larger, in: sector) {
            return UINavigationController(rootViewController: SemSetsVC(oceanLayer: larger))
        }

        return BarrierVC()
    }
}

// Notification
extension SemSectorVC {
    @objc func managedObjectContextObjectsDidChange(notification: NSNotification) {
        guard let semSetsVC = viewControllers!.first!.children.first as? SemSetsVC else {
            return
        }
        setViewControllers(viewControllers!, direction: .reverse, animated: false, completion: nil)
    }
}
