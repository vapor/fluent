extension Tester {
    public func testForeignKeys() throws {
        UserFK.database = database
        PetFK.database = database
        
        database.log = { query in
            print(query)
        }
        
        try UserFK.prepare(database)
        try PetFK.prepare(database)
        defer {
            try! PetFK.revert(database)
            try! UserFK.revert(database)
        }

        
        let user = UserFK(name: "Bob")
        try user.save()
        
        let pet = try PetFK(name: "Spud", userFkId: user.assertExists())
        try pet.save()
        
        do {
            let pet = PetFK(name: "Fail", userFkId: 5)
            try pet.save()
            throw Error.failed("Should not have saved")
        } catch {
            if error is Error {
                // all the should not have saved error thru
                throw error
            }
            // else pass
        }
        
        let pets = try PetFK.all()
        guard pets.count == 1 else {
            throw Error.failed("Pet count should have been one")
        }
    }
}

// MARK: Models

final class UserFK: Entity, Preparation {
    var name: String
    let storage = Storage()
    static let name = "userfk"
    
    init(name: String) {
        self.name = name
    }
    
    init(row: Row) throws {
        name = try row.get("name")
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("name", name)
        return row
    }
    
    static func prepare(_ database: Database) throws {
        try database.create(self) { userfk in
            userfk.id(for: self)
            userfk.string("name")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

final class PetFK: Entity {
    var name: String
    var userFkId: Identifier
    let storage = Storage()
    static let name = "petfk"
    
    init(name: String, userFkId: Identifier) {
        self.name = name
        self.userFkId = userFkId
    }
    
    init(row: Row) throws {
        name = try row.get("name")
        userFkId = try row.get(UserFK.foreignIdKey)
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("name", name)
        try row.set(UserFK.foreignIdKey, userFkId)
        return row
    }
    
    static func prepare(_ database: Database) throws {
        try database.create(self) { petfk in
            petfk.id(for: self)
            petfk.string("name")
            petfk.foreignId(for: UserFK.self)
            petfk.foreignKey(for: UserFK.self)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}
