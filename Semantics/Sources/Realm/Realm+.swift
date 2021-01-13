import RealmSwift

extension Realm {
    static func asyncOpen(partitionValue: String, callbackQueue: DispatchQueue, callback: @escaping (Result<Realm, Swift.Error>) -> Void) {
        var config = RealmSpace.user.configuration(partitionValue: partitionValue)
        config.shouldCompactOnLaunch = RealmSpace.determineCompact
        Realm.asyncOpen(configuration: config, callbackQueue: callbackQueue, callback: callback)
    }
    
    init(partitionValue: String, callbackQueue: DispatchQueue) throws {
        var config = RealmSpace.user.configuration(partitionValue: partitionValue)
        config.shouldCompactOnLaunch = RealmSpace.determineCompact
        try self.init(configuration: config, queue: callbackQueue)
    }
    
    static func newPrivateRealm(queue: DispatchQueue) throws -> Realm {
        try Realm(partitionValue: RealmSpace.userID!, callbackQueue: queue)
    }
}

