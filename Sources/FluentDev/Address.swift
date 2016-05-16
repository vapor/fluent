import Fluent

class Address: Model {
    static var entity: String {
        return "addresses"
    }
    
    var id: String?
    
    func serialize() -> [String: Value?] {
        return [
            "id": id
        ]
    }
    
    required init(serialized: [String: Value]) {
        self.id = serialized["id"]?.string
    }
}
