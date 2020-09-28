//
//  RealmSpace.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/8/12.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import RealmSwift

extension Notification.Name {
    static let clientReset = Notification.Name("clientReset")
}

class RealmSpace {
    static let clientResetQueue = DispatchQueue(label: "Dedicate-For-ClientReset")
    static func prepare() {
        app.syncManager.logLevel = .debug
        app.syncManager.errorHandler = realmSyncErrorHandler
        preloadRealms()
    }
    
    static func preloadRealms() {
        if let userId = RealmSpace.queryCurrentUserID() {
            RealmSpace.shared.realm(partitionValue1: RealmSpace.partitionValue) {_ in
                
            }
            RealmSpace.shared.realm(partitionValue1: userId) {_ in
                
            }
        }
    }
    
    static func handleClientReset() {
                RealmSpace.app.syncManager
        //        Self.clientResetQueue.async {
        //            let group = DispatchGroup()
        //            if let dic = SemUserDefaults.getRealmPathDic() {
        //                for (partitionValue, path) in dic {
        //                    group.wait()
        //                    group.enter()
        //                    RealmSpace.shared.realm(partitionValue: partitionValue) { realm in
        //                        if !FileManager.default.fileExists(atPath: path) {
        //                            fatalError()
        //                        }
        //                        let config = Realm.Configuration(fileURL: URL(fileURLWithPath: path), readOnly: true)
        //                        let oldRealm = try! Realm(configuration: config)
        //                        let objs = oldRealm.objects(Object.self)
                // for write performance: max 1MB per transcation
        //                        try! realm.write {
        //                            for obj in objs {
        //                                realm.create(Object.self, value: obj, update: .modified)
        //                            }
        //                        }
        //                        SemUserDefaults.clearRealmPath(partitionValue: partitionValue)
        //                        try! FileManager.default.removeItem(atPath: path)
        //                        group.leave()
        //                    }
        //                }
        //            }
        //            group.wait()
        //            NotificationCenter.default.post(name: .clientReset, object: nil)
        //        }
    }
    
    static func invalidate(partitioinValue: String) {
        if let realm = main.realms[partitionValue] {
            realm.invalidate()
            main.realms[partitionValue] = nil
        }
        if let realm = shared.realms[partitionValue] {
            realm.invalidate()
            shared.realms[partitionValue] = nil
        }
    }
    
    static let app = App(id: Environment.current.realmApp)
    
    static let shared = RealmSpace(queue: DispatchQueue(label: "Dedicated-For-Realm", qos: .userInitiated))
    
    static let main = RealmSpace(queue: DispatchQueue.main)
    
    private lazy var realms = [String: Realm]()
    
    private lazy var partition2Completions = [String: [(Realm)->Void]]()
    
    let queue: DispatchQueue
    init(queue queue_: DispatchQueue) {
        queue = queue_
    }
    
    func realm(partitionValue1 partitionValue: String) -> Realm {
        if let realm = realms[partitionValue] {
            if (!realm.autorefresh) {
                realm.refresh()
            }
            return realm
        }
        
        let tmp = newRealm(partitionValue)
        realms[partitionValue] = tmp
        return tmp
    }
    
    func realm(partitionValue1 partitionValue: String, completion: @escaping (Realm) -> Void) {
        if let realm = realms[partitionValue] {
            if (!realm.autorefresh) {
                realm.refresh()
            }
            completion(realm)
            return
        }
        
        guard partition2Completions[partitionValue] == nil else {
            partition2Completions[partitionValue]!.append(completion)
            return
        }
        
        partition2Completions[partitionValue] = [completion]
        newRealm(partitionValue) {
            self.realms[partitionValue] = $0
            let completions = self.partition2Completions[partitionValue]!
            self.partition2Completions[partitionValue] = nil
            for completion in completions {
                completion($0)
            }
        }
    }
    
    private func newRealm(_ partitionValue: String) -> Realm {
        var config = Self.queryCurrentUser()!.configuration(partitionValue: partitionValue)
        config.shouldCompactOnLaunch = determineCompact
        return try! Realm(configuration: config, queue: queue)
    }
    
    private func newRealm(_ partitionValue: String, completion: @escaping (Realm) -> Void) {
        let user = Self.queryCurrentUser()!
        
        var config = user.configuration(partitionValue: partitionValue)
        config.shouldCompactOnLaunch = determineCompact
        Realm.asyncOpen(configuration: config, callbackQueue: queue) { (realm, error) in
            guard let realm = realm, error == nil else {
                fatalError("[Open Realm] \(error!)")
            }
            completion(realm)
        }
    }
        
    private func determineCompact(fileSize: Int, dataSize: Int) -> Bool {
        // Compact if the file is over 100MB in size and less than 50% 'used'
        let oneHundredMB = 100 * 1024 * 1024
        return (fileSize > oneHundredMB) && (Double(dataSize) / Double(fileSize)) < 0.5
    }
    
    static let partitionValue = "Public18"
}
// MARK: Threading
extension RealmSpace {
    func async(_ block: @escaping () -> Void) {
        queue.async(execute: block)
    }
}


// MARK: Account
extension RealmSpace {
    static var currentUser: User?
    
    static func queryCurrentUser() -> User? {
        if currentUser == nil {
            currentUser = app.currentUser()
        }
        
        return currentUser
    }
    
    static func queryCurrentUserID() -> String? {
        queryCurrentUser()?.id
    }
    
    static func login(appleToken: String, completion: @escaping () -> Void) {
        // Decoding: https://jwt.io/
        Self.app.login(credentials: Credentials(appleToken: appleToken)) { (user, error) in
            guard error == nil else {
                fatalError("\(error)")
            }
            completion()
        }
    }
}

// MARK: Functions

extension RealmSpace {
    struct SearchNextQuery {
        let placeId: String
        let conditions: [ConditionInfo]
        
        func bson() -> AnyBSON {
            AnyBSON.document([
                "placeId": AnyBSON.string(placeId),
                "conditions": AnyBSON.array(conditions.map { $0.bson()} )
            ])
        }
        
        struct ConditionInfo {
            let conditionId: String
            let nextOperator: NextOperator
            
            func bson() -> AnyBSON {
                AnyBSON.document([
                    "conditionId": AnyBSON.string(conditionId),
                    "nextOperator": AnyBSON.int32(Int32(nextOperator.rawValue))
                ])
            }
        }
    }
    struct SearchNextResult {
        let places: [PlaceConditions]
        
        init(from bson: AnyBSON) {
            guard case let AnyBSON.document(doc) = bson else {
                fatalError()
            }
            
            guard case let AnyBSON.array(array) = doc["places"]!! else {
                fatalError()
            }
            
            places = array.map {
                PlaceConditions(from: $0!)
            }
        }
        struct PlaceConditions {
            let placeId: String
            let conditions: [ConditionInfo]
            
            init(from bson: AnyBSON) {
                let doc = bson.documentValue!
                
                placeId = doc["placeId"]!!.stringValue!
                
                conditions = doc["conditions"]!!.arrayValue!.map {
                    ConditionInfo(from: $0!)
                }
            }
            
            struct ConditionInfo {
                let id: String
                let backers: [BackerInfo]
                
                init(from bson: AnyBSON) {
                    id = bson.documentValue!["id"]!!.stringValue!
                    backers = bson.documentValue!["backers"]!!.arrayValue!.map {
                        BackerInfo(from: $0!)
                    }
                }
                
                struct BackerInfo {
                    let id: String
                    let title: String
                    
                    init(from bson: AnyBSON) {
                        let doc = bson.documentValue!
                        id = doc["id"]!!.stringValue!
                        title = doc["title"]!!.stringValue!
                    }
                }
            }
        }
    }
    
    func searchNext(query: SearchNextQuery, completion: @escaping (SearchNextResult) -> Void) {
        let f: Functions.Function = Self.queryCurrentUser()!.functions[dynamicMember: "searchNext"]
        let bt1 = Date().timeIntervalSince1970
        f([query.bson()]) { r, error in
            print("[Measure] f:searchNext \(Date().timeIntervalSince1970 - bt1)")
            guard error == nil else {
                fatalError("\(error!.localizedDescription)")
            }

            let rr = SearchNextResult(from: r!)
            print("searchNextResult \(rr)")
            self.queue.async {
                completion(rr)
            }
        }
        
        let dumb: Functions.Function = Self.queryCurrentUser()!.functions[dynamicMember: "dumb1"]
        let btDumb = Date().timeIntervalSince1970
        dumb([]) { (_, _) in
            print("[Measure] f:dumb \(Date().timeIntervalSince1970 - btDumb)")
        }
    }
}
