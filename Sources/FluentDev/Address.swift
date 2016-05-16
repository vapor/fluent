
import Fluent

class Address: Model {
    var id: String?
    
    required init(unboxer: Unboxer) {
        id = unboxer.unbox("id")
    }
}
