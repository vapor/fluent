import Fluent

class Address: Model {
    static var entity: String {
        return "addresses"
    }
    
    var id: Value?
    
    func serialize() -> [String: Value?] {
        return [:]
    }
    
    required init(serialized: [String: Value]) {
    }
}
