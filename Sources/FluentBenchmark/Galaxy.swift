import Fluent
import Foundation

final class Galaxy: FluentModel {
    var storage: FluentStorage
    
    var entity: String {
        return "galaxies"
    }
    
    var id: Field<UUID> {
        return self.field("id")
    }
    
    var name: Field<String> {
        return self.field("name")
    }
    
    var allFields: [AnyFluentField] {
        return [id, name]
    }
    
    init(storage: FluentStorage) {
        self.storage = storage
    }
}
