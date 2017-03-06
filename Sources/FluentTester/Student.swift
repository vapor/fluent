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
    
    init(node: Node) throws {
        name = try node.get("name")
        age = try node.get("age")
        ssn = try node.get("ssn")
        donor = try node.get("donor")
        meta = try node.get("meta")
        id = try node.get(idKey)
    }
    
    func makeNode(in context: Context?) throws -> Node {
        var node = Node([:])
        try node.set(idKey, id)
        try node.set("name", name)
        try node.set("age", age)
        try node.set("ssn", ssn)
        try node.set("donor", donor)
        try node.set("meta", meta)
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
