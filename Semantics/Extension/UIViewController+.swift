//
//  UIViewController+.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/6/5.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import UIKit
import CoreData

extension UIViewController {
    var appDelegate: AppDelegate {
        return (UIApplication.shared.delegate as! AppDelegate)
    }
    
    var managedObjectContext: NSManagedObjectContext {
        return appDelegate.persistentContainer.viewContext
    }
}
