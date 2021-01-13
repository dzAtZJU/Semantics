protocol Reusable {}

class Pool<T> {
    var instances: [T]
    
    init(instances instances_: [T]) {
        instances = instances_
    }
    
    func get() -> T {
        instances.removeLast()
    }
    
    func put(_ instance: T) {
        instances.append(instance)
    }
}
