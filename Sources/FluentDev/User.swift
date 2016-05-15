import Fluent

class User: Model {
    var id: String?
    var name: String
    
    init(name: String) {
        self.name = name
    }
    
    required convenience init(unboxer: Unboxer) {
        self.init(name: unboxer.unbox("name"))
    }
}