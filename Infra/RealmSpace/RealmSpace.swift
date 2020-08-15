//
//  RealmSpace.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/8/12.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import RealmSwift

class RealmSpace {
    static let shared = RealmSpace()
    
    lazy var queue = DispatchQueue(label: "Dedicated-For-Realm", qos: .userInitiated)
    
    private(set) var app: RealmApp!
    
    private(set) var publicRealm: Realm!
    
    private init() {
        app = RealmApp(id: "semantics-tonbj")
    }
    
    func newRealm(_ partitionValue: String) -> Realm {
        let user = AccountLayer.shared.queryCurrentUser()!
        return try! Realm(configuration: user.configuration(partitionValue: partitionValue), queue: queue)
    }
    
    func loadPublicRealm() {
        let user = AccountLayer.shared.queryCurrentUser()!
            self.publicRealm = try! Realm(configuration: user.configuration(partitionValue: "Public"))
        
        
    }
}

