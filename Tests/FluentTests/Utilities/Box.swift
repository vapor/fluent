import Fluent

final class Box: Entity, Preparation {
    var name: String
    var weight: Int
    let storage = Storage()
    
    init(name: String, weight: Int) {
        self.name = name
        self.weight = weight
    }
    
    init(row: Row) throws {
        name = try row.get("name")
        weight = try row.get("weight")
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("name", name)
        try row.set("weight", weight)
        return row
    }
    
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string("name")
            builder.int("weight")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

