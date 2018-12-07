import Fluent
import Foundation

final class Planet: FluentModel {
    var storage: FluentStorage
    
    var properties: [FluentProperty] {
        return [id, name, galaxy]
    }
    
    var entity: String {
        return "planets"
    }
    
    var id: Field<Int> {
        return self.field("id")
    }
    
    var name: Field<String> {
        return self.field("name")
    }
    
    var galaxy: Parent<Galaxy> {
        return self.parent("galaxyID")
    }
    
    init(storage: FluentStorage) {
        self.storage = storage
    }
}
