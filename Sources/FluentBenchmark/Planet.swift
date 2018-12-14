import Fluent
import Foundation

final class Planet: Model {
    var storage: Storage
    
    var properties: [Property] {
        return [id, name, galaxy]
    }
    
    var entity: String {
        return "planets"
    }
    
    var id: ModelField<Planet, Int> {
        return self.field("id", .int, .primaryKey)
    }
    
    var name: ModelField<Planet, String> {
        return self.field("name")
    }
    
    var galaxy: ParentRelation<Planet, Galaxy> {
        return self.parent("galaxyID")
    }
    
    init(storage: Storage) {
        self.storage = storage
    }
}
