import Fluent

final class Student: Entity {
    var name: String
    var age: Int
    var ssn: String
    var donor: Bool
    var meta: Node?
    
    let storage = Storage()
    
    init(name: String, age: Int, ssn: String, donor: Bool, meta: Node) {
        self.name = name
        self.age = age
        self.ssn = ssn
        self.donor = donor
        self.meta = meta
    }
    
    init(node: Node, in context: Context) throws {
        name = try node.extract("name")
        age = try node.extract("age")
        ssn = try node.extract("ssn")
        donor = try node.extract("donor")
        meta = try node.extract("meta")

        id = try node.extract(idKey)
    }
    
    func makeNode(context: Context) throws -> Node {
        let node = try Node(node: [
            idKey: id,
            "name": name,
            "age": age,
            "ssn": ssn,
            "donor": donor,
            "meta": meta
        ])
        return node
    }
    
    static func prepare(_ database: Database) throws {
        try database.create(self) { students in
            students.id(for: self)
            students.string("name", length: 64)
            students.int("age")
            students.string("ssn", unique: true)
            students.bool("donor", default: true)
        }
        
        // separate to ensure modification works
        try database.modify(self) { students in
            students.custom("meta", type: "JSON", optional: true)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}
