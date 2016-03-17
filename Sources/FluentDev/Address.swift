
import Fluent

class Address: Model {
    static var entity: String {
        return "photo"
    }
    
    var id: String? {
        return "0"
    }
    
    func serialize() -> [String: Value] {
        return [:]
    }
    
    required init(deserialize: [String: Value]) {
        
    }
}
