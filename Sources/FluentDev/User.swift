import Fluent

class User: Model {
    init(name: String) {
        self.name = name
    }
    
    var id: Value?
    var name: String
    
    func serialize() -> [String: Value?] {
        return [
            "name": self.name
        ]
    }
    
    required init(serialized: [String: Value]) {
        name = serialized["name"]?.string ?? ""
    }
}