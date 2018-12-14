import Fluent
import Foundation

final class Galaxy: Model {
    var storage: Storage
    
    var properties: [Property] {
        return [id, name]
    }
    
    var entity: String {
        return "galaxies"
    }
    
    var id: ModelField<Galaxy, Int> {
        return self.field("id", .int, .primaryKey)
    }
    
    var name: ModelField<Galaxy, String> {
        return self.field("name")
    }
    
    var planets: ChildrenRelation<Galaxy, Planet> {
        return self.children(\.galaxy)
    }
    
    init(storage: Storage) {
        self.storage = storage
    }
}
