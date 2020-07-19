//
//  SemSectorVC.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/7/18.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import UIKit

class SemSectorsVC: UIPageViewController {
    
    init(firstSector: Sector) {
        super.init(transitionStyle: .scroll, navigationOrientation: .vertical)
        
        dataSource = self
        setViewControllers([SemSectorVC(sector: firstSector)], direction: .forward, animated: false, completion: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange), name: .NSManagedObjectContextObjectsDidChange, object: managedObjectContext)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SemSectorsVC: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let sectorVC = viewController as! SemSectorVC
        guard let nextSector = SectorDataLayer.shared.queryByDisplayOrder(Int(sectorVC.sector.displayOrder), operator: .less) else {
            return nil
        }

        return SemSectorVC(sector: nextSector)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let sectorVC = viewController as! SemSectorVC
        guard let nextSector = SectorDataLayer.shared.queryByDisplayOrder(Int(sectorVC.sector.displayOrder), operator: .larger) else {
            return nil
        }

        return SemSectorVC(sector: nextSector)
    }
}

extension SemSectorsVC {
    @objc func managedObjectContextObjectsDidChange() {
        setViewControllers(viewControllers, direction: .reverse, animated: false, completion: nil)
    }
}
