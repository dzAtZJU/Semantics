import RealmSwift
import Combine

// Current Approach: After app launch, (AsyncOpen)+(SyncOpen)*

extension Notification.Name {
    static let realmsPreloaded = Notification.Name("realmsPreloaded")
    static let clientReset = Notification.Name("clientReset")
}

class RealmSpace {
    static func load() {
        app.syncManager.logLevel = .debug
        app.syncManager.errorHandler = realmSyncErrorHandler
        preloadRealms()
    }
    
    static let userInitiated = RealmSpace(queue: DispatchQueue(label: "serial-for-realm", qos: .userInitiated))
    
    static let main = RealmSpace(queue: DispatchQueue.main)
    
    static let publicPartitionValue = "Public18"
    
    private static let app = App(id: Environment.current.realmApp)
    
    private static func preloadRealms() {

        let loadAll = { (userId: String) -> Void in
            let group = DispatchGroup()
            group.enter()
            RealmSpace.userInitiated.realm(publicPartitionValue) { _ in
                group.leave()
            }
            group.enter()
            RealmSpace.userInitiated.realm(userId) { _ in
                group.leave()
            }
            group.notify(queue: .main) {
                NotificationCenter.default.post(name: .realmsPreloaded, object: nil)
            }
        }
        if let userId = RealmSpace.userID {
            loadAll(userId)
        } else {
            RealmSpace.login(cred: Credentials.anonymous) { userId in
                loadAll(userId)
            }
        }
    }
    
    let queue: DispatchQueue
    
    init(queue: DispatchQueue) {
        self.queue = queue
    }
    
    var publicRealm: Realm {
        realm(Self.publicPartitionValue)
    }
    
    var privatRealm: Realm {
        realm(Self.userID)
    }
    
    func publicRealm(completion: @escaping (Realm) -> Void) {
        realm(Self.publicPartitionValue, completion: completion)
    }
    
    func privatRealm(completion: @escaping (Realm) -> Void) {
        realm(Self.userID, completion: completion)
    }
    
    func async(_ block: @escaping () -> Void) {
        queue.async(execute: block)
    }
    
    func realm(_ partitionValue: String) -> Realm {
        var config = Self.user.configuration(partitionValue: partitionValue)
        config.shouldCompactOnLaunch = Self.determineCompact
        return try! Realm(configuration: config, queue: queue)
    }
    
    func realm(_ partitionValue: String, completion: @escaping (Realm) -> Void) {
        var config = Self.user.configuration(partitionValue: partitionValue)
        config.shouldCompactOnLaunch = Self.determineCompact
        Realm.asyncOpen(configuration: config, callbackQueue: queue) { (realm, error) in
            guard let realm = realm, error == nil else {
                fatalError("[Open Realm] \(error!)")
            }
            completion(realm)
        }
    }
    
    private static func determineCompact(fileSize: Int, dataSize: Int) -> Bool {
        // Compact if the file is over 100MB in size and less than 50% 'used'
        let oneHundredMB = 100 * 1024 * 1024
        return (fileSize > oneHundredMB) && (Double(dataSize) / Double(fileSize)) < 0.5
    }
}

// MARK: Account
extension RealmSpace {
    static var user: User! {
        app.currentUser
    }
    
    static var userID: String! {
        user?.id
    }
    
    static func login(cred: Credentials, completion: @escaping (String) -> Void) {
        // Decoding: https://jwt.io/
        Self.app.login(credentials: cred) { (user, error) in
            guard error == nil, let userId = user?.id else {
                fatalError("\(error)")
            }
            RealmSpace.userInitiated.realm(userId) { privateRealm in
                _ = privateRealm.queryOrCreateCurrentIndividual(userName: KeychainItem.currentUserName ?? String.random(ofLength: 6))
                completion(userId)
            }
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
        let f: Functions.Function = Self.user.functions[dynamicMember: "searchNext"]
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
        
        let dumb: Functions.Function = Self.user.functions[dynamicMember: "dumb1"]
        let btDumb = Date().timeIntervalSince1970
        dumb([]) { (_, _) in
            print("[Measure] f:dumb \(Date().timeIntervalSince1970 - btDumb)")
        }
    }
}

//static let clientResetQueue = DispatchQueue(label: "Dedicate-For-ClientReset")
//static func handleClientReset() {
//    RealmSpace.app.syncManager
//            Self.clientResetQueue.async {
//                let group = DispatchGroup()
//                if let dic = SemUserDefaults.getRealmPathDic() {
//                    for (partitionValue, path) in dic {
//                        group.wait()
//                        group.enter()
//                        RealmSpace.shared.realm(partitionValue: partitionValue) { realm in
//                            if !FileManager.default.fileExists(atPath: path) {
//                                fatalError()
//                            }
//                            let config = Realm.Configuration(fileURL: URL(fileURLWithPath: path), readOnly: true)
//                            let oldRealm = try! Realm(configuration: config)
//                            let objs = oldRealm.objects(Object.self)
//     for write performance: max 1MB per transcation
//                            try! realm.write {
//                                for obj in objs {
//                                    realm.create(Object.self, value: obj, update: .modified)
//                                }
//                            }
//                            SemUserDefaults.clearRealmPath(partitionValue: partitionValue)
//                            try! FileManager.default.removeItem(atPath: path)
//                            group.leave()
//                        }
//                    }
//                }
//                group.wait()
//                NotificationCenter.default.post(name: .clientReset, object: nil)
//            }
//}
