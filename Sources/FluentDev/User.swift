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
        id = serialized["id"]?.string
        name = serialized["name"]?.string ?? ""
    }
}