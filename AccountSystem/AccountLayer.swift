//
//  AccountLayer.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/8/12.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import RealmSwift

class AccountLayer {
    private init() {}
    
    static let shared = AccountLayer()
    
    var currentUser: SyncUser? {
        RealmSpace.shared.app.currentUser()
    }
    
    var currentUserID: String? {
        currentUser?.identity
    }
    
    func login(appleToken: String, completion: @escaping () -> Void) {
        RealmSpace.shared.app.login(withCredential: AppCredentials(appleToken: appleToken)) { (user, error) in
            guard error == nil else {
                fatalError("\(error)")
            }
            completion()
        }
    }
}
