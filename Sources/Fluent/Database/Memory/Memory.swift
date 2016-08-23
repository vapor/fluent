import Node

public class Memory {
    typealias Storage = [String: Node]
    
    internal var store: Storage = Storage()
    
    public subscript(key: String) -> Node? {
        get {
            return value(forKey: key)
        }
        
        set {
            set(newValue, forKey: key)
        }
    }

    public func contains(key: String) -> Bool {
        return self.store[key] != nil
    }
    
    public func purge() {
        self.store = [:]
    }
    
    public func set(_ value: Node?, forKey key: String) {
        self.store[key] = value
    }
    
    public func value(forKey key: String) -> Node? {
        return self.store[key]
    }

    deinit {
        purge()
    }
}
