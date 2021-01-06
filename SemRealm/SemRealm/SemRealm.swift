import RealmSwift

public extension List {
    var array: Array<Element> {
        Array(self)
    }
}

public extension Realm {
    var partitionValue: String? {
        configuration.syncConfiguration?.partitionValue
    }
}
