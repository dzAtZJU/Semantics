//
//  CloudSync.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/8/5.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import CoreData
import Foundation

class CloudSync: CoreDataAccessor {
    private var lastToken_: NSPersistentHistoryToken?
    
    private init() {
        NotificationCenter.default.addObserver(self, selector: #selector(persistentStoreRemoteChanged), name: .NSPersistentStoreRemoteChange, object: appPersistentContainer.persistentStoreCoordinator)
    }
    
    static let `default` = CloudSync()
    
    func loadLastToken() {
//        if let data = try? Data(contentsOf: Files.cloudSyncToken()) {
//            lastToken_ = try! NSKeyedUnarchiver.unarchivedObject(ofClass: NSPersistentHistoryToken.self, from: data)
//        }
    }
    
    var lastToken: NSPersistentHistoryToken? {
        get {
            lastToken_
        }
        set {
            precondition(newValue != nil)
            lastToken_ = newValue
//            let data = try! NSKeyedArchiver.archivedData(withRootObject: newValue!, requiringSecureCoding: false)
//            try! data.write(to: Files.cloudSyncToken())
        }
    }
    
    @objc private func persistentStoreRemoteChanged(notification: Notification) {
        let fetchHistoryRequest = NSPersistentHistoryChangeRequest.fetchHistory(
            after: lastToken
        )

        appPersistentContainer.performBackgroundTask { context in
            guard
                let historyResult = try? context.execute(fetchHistoryRequest)
                    as? NSPersistentHistoryResult,
                let transactions = historyResult.result as? [NSPersistentHistoryTransaction]
                else {
                    fatalError("Could not convert history result to transactions.")
            }
    
            guard !transactions.isEmpty else { return }
            
            for transaction in transactions {
                self.appManagedObjectContext.perform {
                    self.appManagedObjectContext.mergeChanges(fromContextDidSave: transaction.objectIDNotification())
                }
            }
            
            self.lastToken = transactions.first!.token
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
