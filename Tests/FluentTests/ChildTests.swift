import XCTest
import Fluent

class ChildTests: XCTestCase {
    
    static let allTests = [
        ("testChildRelations", testChildRelations)
    ]
    
    func testChildRelations() throws {
        let memoryDriver = MemoryDriver()
        let database = Database(memoryDriver)
        
        try database.prepare(Owner.self)
        try database.prepare(Pet.self)
        
        var owner1 = Owner(name: "John")
        try owner1.save()
        
        var pet1 = Pet(name: "Fodo", owner: owner1)
        try pet1.save()
        
        let petsOwner = try pet1.getOwner()
        
        XCTAssertNotNil(petsOwner)
        
        let pets = try owner1.getPets()
        
        XCTAssertNotEqual(0, pets.count)
    }
    
}

class Owner: Entity {
    var id: Node?
    var exists: Bool = false
    
    var name: String
    
    init(name: String) {
        self.name = name
    }
    
    required init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        name = try node.extract("name")
    }
    
    static func prepare(_ database: Fluent.Database) throws {
        try database.create(entity) { pet in
            pet.id()
            pet.string("name")
        }
    }
    static func revert(_ database: Fluent.Database) throws {
        try database.delete(Owner.entity)
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node:[
            "id": id,
            "name": name,
            ])
    }
    
    func getPets() throws -> [Pet] {
        return try children(nil, Pet.self).all()
    }
}

class Pet: Entity {
    var id: Node?
    var name: String
    var exists: Bool = false
    var ownerId: Node?
    
    init(name: String, owner: Owner) {
        self.name = name
        self.ownerId = owner.id
    }
    
    required init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        name = try node.extract("name")
        ownerId = try node.extract("owner_id")
    }
    
    static func prepare(_ database: Fluent.Database) throws {
        try database.create(entity) { pet in
            pet.id()
            pet.string("name")
            pet.parent(Owner.self, optional: false)
        }
    }
    static func revert(_ database: Fluent.Database) throws {
        try database.delete(Pet.entity)
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node:[
            "id": id,
            "name": name,
            "owner_id": ownerId
        ])
    }
    
    func getOwner() throws -> Owner? {
        return try parent(ownerId, nil, Owner.self).get()
    }
    
}

