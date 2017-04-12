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
    
    init(row: Row) throws {
        name = try row.get("name")
        age = try row.get("age")
        ssn = try row.get("ssn")
        donor = try row.get("donor")
        meta = try row.get("meta")
        id = try row.get(idKey)
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(idKey, id)
        try row.set("name", name)
        try row.set("age", age)
        try row.set("ssn", ssn)
        try row.set("donor", donor)
        try row.set("meta", meta)
        return row
    }
    
    static func prepare(_ database: Database) throws {
        try database.create(self) { students in
            students.id()
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
