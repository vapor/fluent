import Fluent

class User: Model {
    static var entity: String {
        return "users"
    }
    
    init(name: String) {
        self.name = name
    }
    
    var id: String?
    var name: String
    
    func serialize() -> [String: Value?] {
        return [
            "id": self.id,
            "name": self.name
        ]
    }
    
    required init(serialized: [String: Value]) {
        if let id = serialized["id"]?.fuzzyString {
            self.id = id
        } else if let id = serialized["_id"]?.fuzzyString {
            self.id = id
        }
        
        name = serialized["name"]?.string ?? ""
    }
}