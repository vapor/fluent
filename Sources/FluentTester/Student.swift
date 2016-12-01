import Fluent

final class Student: Entity {
    var id: Node?
    
    var name: String
    var age: Int
    var ssn: String
    var donor: Bool
    var meta: Node
    
    var exists = false
    
    init(name: String, age: Int, ssn: String, donor: Bool, meta: Node) {
        self.name = name
        self.age = age
        self.ssn = ssn
        self.donor = donor
        self.meta = meta
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        name = try node.extract("name")
        age = try node.extract("age")
        ssn = try node.extract("ssn")
        donor = try node.extract("donor")
        meta = try node.extract("meta")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "name": name,
            "age": age,
            "ssn": ssn,
            "donor": donor,
            "meta": meta
        ])
    }
    
    static func prepare(_ database: Database) throws {
        try database.create("students") { students in
            students.id()
            students.string("name", length: 64)
            students.int("age")
            students.string("ssn", unique: true)
            students.bool("donor", default: true)
        }
        
        // separate to ensure modification works
        try database.modify("students") { students in
            students.custom("meta", type: "JSON")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("students")
    }
}
