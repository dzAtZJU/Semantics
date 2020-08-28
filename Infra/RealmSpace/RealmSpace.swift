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
    
    func newRealm(partitionValue: String = RealmSpace.partitionValue, completion: @escaping (Realm?) -> Void) {
        guard let user = queryCurrentUser() else {
            completion(nil)
            return
        }
        Realm.asyncOpen(configuration: user.configuration(partitionValue: partitionValue)) { (realm, error) in
            completion(realm!)
        }
    }
}


// MARK: Functions

extension RealmSpace {
    struct SearchNextQuery {
        let placeId: ObjectId
        let conditions: [ConditionInfo]
        
        func bson() -> AnyBSON {
            AnyBSON.document([
                "placeId": AnyBSON.objectId(placeId),
                "conditions": AnyBSON.array(conditions.map { $0.bson()} )
            ])
        }
        
        struct ConditionInfo {
            let conditionId: ObjectId
            let nextOperator: NextOperator
            
            func bson() -> AnyBSON {
                AnyBSON.document([
                    "conditionId": AnyBSON.objectId(conditionId),
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
            let placeId: ObjectId
            let conditions: [ConditionInfo]
            
            init(from bson: AnyBSON) {
                let doc = bson.documentValue!
                
                placeId = doc["placeId"]!!.objectIdValue!
                
                conditions = doc["conditions"]!!.arrayValue!.map {
                    ConditionInfo(from: $0!)
                }
            }
            
            struct ConditionInfo {
                let id: ObjectId
                let backers: [BackerInfo]
            
                init(from bson: AnyBSON) {
                    id = bson.documentValue!["id"]!!.objectIdValue!
                    backers = bson.documentValue!["backers"]!!.arrayValue!.map {
                        BackerInfo(from: $0!)
                    }
                }
                
                struct BackerInfo {
                    let id: ObjectId
                    let title: String
                    
                    init(from bson: AnyBSON) {
                        let doc = bson.documentValue!
                        id = doc["id"]!!.objectIdValue!
                        title = doc["title"]!!.stringValue!
                    }
                }
            }
        }
    }
    
    func searchNext(query: SearchNextQuery, completion: @escaping (SearchNextResult) -> Void) {
        let f = app.functions[dynamicMember: "searchNext"]
        f([query.bson()]) { r, error in
            guard error == nil else {
                fatalError("\(error!.localizedDescription)")
            }

            let rr = SearchNextResult(from: r!)
            print("searchNextResult \(rr)")
            self.queue.async {
                completion(rr)
            }
        }
    }
}
