import Fluent

class User: Model {
    static var entity: String {
        return "user"
    }
    
    var id: String? {
        return "0"
    }
    
    func serialize() -> [String: StatementValueType] {
        return [:]
    }
    
    required init(deserialize: [String: StatementValueType]) {
        
    }
}