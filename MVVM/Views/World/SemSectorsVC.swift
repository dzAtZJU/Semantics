//
//  SemSectorVC.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/7/18.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import UIKit
import CoreData

class SemSectorsVC: UIPageViewController {
    
    private let topOrganVC = UINavigationController(rootViewController: OrganVC())
    
    private let bottomOrganVC = UINavigationController(rootViewController: OrganVC())
    
    init(firstSector: Sector) {
        super.init(transitionStyle: .scroll, navigationOrientation: .vertical)
        
        dataSource = self
        setViewControllers([SemSectorVC(sector: firstSector)], direction: .forward, animated: false, completion: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange), name: .NSManagedObjectContextObjectsDidChange, object: appManagedObjectContext)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SemSectorsVC: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if viewController == topOrganVC {
            return nil
        }
        
        if viewController == bottomOrganVC {
            return SemSectorVC(sector: SectorDataLayer.shared.queryByDisplayOrderEnding(.max) ?? Sector(context: appManagedObjectContext))
        }
        
        let sectorVC = viewController as! SemSectorVC
        if let nextSector = SectorDataLayer.shared.queryByDisplayOrder(Int(sectorVC.sector.displayOrder), operator: .less) {
            return SemSectorVC(sector: nextSector)
        }

        return topOrganVC
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if viewController == bottomOrganVC {
            return nil
        }
        
        if viewController == topOrganVC {
            return SemSectorVC(sector: SectorDataLayer.shared.queryByDisplayOrderEnding(.min) ?? Sector(context: appManagedObjectContext))
        }
        
        let sectorVC = viewController as! SemSectorVC
        if let nextSector = SectorDataLayer.shared.queryByDisplayOrder(Int(sectorVC.sector.displayOrder), operator: .larger) {
            return SemSectorVC(sector: nextSector)
        }

        return bottomOrganVC
    }
}

extension SemSectorsVC {
    @objc func managedObjectContextObjectsDidChange(notification: NSNotification) {
        guard let sectorVC = viewControllers!.first as? SemSectorVC else {
            return
        }
        
        if let deleted = notification.userInfo?[NSDeletedObjectsKey] as? Set<NSManagedObject>, deleted.count > 0, deleted.contains(sectorVC.sector) {
            if let prev = pageViewController(self, viewControllerBefore: viewControllers!.first!) {
                setViewControllers([prev], direction: .reverse, animated: true, completion: nil)
                return
            }
            
            if let next = pageViewController(self, viewControllerAfter: viewControllers!.first!) {
                setViewControllers([next], direction: .forward, animated: true, completion: nil)
                return
            }
            setViewControllers([SemSectorVC(sector: Sector(context: appManagedObjectContext))], direction: .forward, animated: true, completion: nil)
        } else {
            setViewControllers(viewControllers!, direction: .reverse, animated: false, completion: nil)
        }
    }
}
