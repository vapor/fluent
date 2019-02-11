import FluentKit



final class User: FluentModel {
    var storage: Storage
    
    var properties: [Property] {
        return [id, name, pet.property]
    }
    
    var entity: String {
        return "users"
    }
    
    var id: Field<Int> {
        return self.field("id", .int, .identifier)
    }
    
    var name: Field<String> {
        return self.field("name", .string, .required)
    }
    
    var pet: Pet {
        return self.nested("pet", .json, .required)
    }
    
    init(storage: Storage) {
        self.storage = storage
    }
}

enum Animal: String, Codable {
    case cat, dog
}

final class Pet: FluentNestedModel {
    var storage: Storage
    
    var properties: [Property] {
        return [name, type]
    }
    
    var name: Field<String> {
        return self.field("name")
    }
    
    var type: Field<Animal> {
        return self.field("type")
    }
    
    init(storage: Storage) {
        self.storage = storage
    }
}

final class UserSeed: FluentMigration {
    init() { }
    
    func prepare(on database: FluentDatabase) -> EventLoopFuture<Void> {
        let tanner = User()
        tanner.name.set(to: "Tanner")
        tanner.pet.name.set(to: "Ziz")
        tanner.pet.type.set(to: .cat)

        let logan =  User()
        logan.name.set(to: "Logan")
        logan.pet.name.set(to: "Runa")
        logan.pet.type.set(to: .dog)
        
        return logan.save(on: database)
            .and(tanner.save(on: database))
            .map { _ in }
    }
    
    func revert(on database: FluentDatabase) -> EventLoopFuture<Void> {
        return database.eventLoop.makeSucceededFuture(())
    }
}
