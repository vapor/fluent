import FluentKit



final class User: FluentModel {
    var storage: Storage
    
    var properties: [Property] {
        return [id, name, pet]
    }
    
    var entity: String {
        return "users"
    }
    
    var id: Field<Int> {
        return self.field("id", .int, .primaryKey)
    }
    
    var name: Field<String> {
        return self.field("name")
    }
    
    var pet: Pet {
        return self.nested("pet")
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
        return [nickname, animal]
    }
    
    var nickname: Field<String> {
        return self.field("nickname")
    }
    
    var animal: Field<Animal> {
        return self.field("animal")
    }
    
    init(storage: Storage) {
        self.storage = storage
    }
}

final class UserSeed: FluentMigration {
    init() { }
    
    func prepare(on database: FluentDatabase) -> EventLoopFuture<Void> {
        let tanner = User.new()
        tanner.name.set(to: "Tanner")
        tanner.pet.nickname.set(to: "Ziz")
        tanner.pet.animal.set(to: .cat)
        
        let logan =  User.new()
        logan.name.set(to: "Logan")
        logan.pet.nickname.set(to: "Runa")
        logan.pet.animal.set(to: .dog)
        
        return logan.save(on: database).and(tanner.save(on: database))
            .map { _ in }
    }
    
    func revert(on database: FluentDatabase) -> EventLoopFuture<Void> {
        return database.eventLoop.makeSucceededFuture(())
    }
}
