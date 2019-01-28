import Fluent
import Foundation

final class Planet: FluentModel {
    var storage: Storage
    
    var fields: [AnyField] {
        return [id, name, galaxy.id]
    }
    
    var entity: String {
        return "planets"
    }
    
    var id: Field<Int> {
        return self.field("id", .int, .primaryKey)
    }
    
    var name: Field<String> {
        return self.field("name")
    }
    
    var galaxy: Parent<Galaxy> {
        return self.parent("galaxyID")
    }
    
    init(storage: Storage) {
        self.storage = storage
    }
}
