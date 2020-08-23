//
//  RealmSpace.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/8/12.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import RealmSwift

class RealmSpace {
    static let partitionValue = "Public2"
    
    static let shared = RealmSpace(queue: DispatchQueue(label: "Dedicated-For-Realm", qos: .userInitiated))
    
    static let main = RealmSpace(queue: DispatchQueue.main)
    
    let queue: DispatchQueue
    
    private(set) var app: RealmApp
    
    init(queue queue_: DispatchQueue) {
        queue = queue_
        app = RealmApp(id: "semantics-tonbj")
    }
}
// MARK: Threading
extension RealmSpace {
    func async(_ block: @escaping () -> Void) {
        queue.async(execute: block)
    }
}


// MARK: Account
extension RealmSpace {
    func queryCurrentUser() -> SyncUser? {
        app.currentUser()
    }
    
    func queryCurrentUserID() -> String? {
        queryCurrentUser()?.identity
    }
    
    func login(appleToken: String, completion: @escaping () -> Void) {
        app.login(withCredential: AppCredentials(appleToken: appleToken)) { (user, error) in
            guard error == nil else {
                fatalError("\(error)")
            }
            completion()
        }
    }
}

// MARK: Realm
extension RealmSpace {
    func newRealm(_ partitionValue: String = RealmSpace.partitionValue) -> Realm {
        let user = queryCurrentUser()!
        return try! Realm(configuration: user.configuration(partitionValue: partitionValue), queue: queue)
    }
}

