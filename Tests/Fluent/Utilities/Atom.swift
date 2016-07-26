import Fluent

final class Atom: Entity {
    var id: Node?
    var name: String
    var protons: Int

    init(name: String, protons: Int) {
        id = nil
        self.name = name
        self.protons = protons
    }

    init(with node: Node, in context: Context) throws {
        id = try node.extract("id")
        name = try node.extract("name")
        protons = try node.extract("protons")
    }

    func makeNode() throws -> Node {
        return try Node([
            "id": id,
            "name": name,
            "protons": protons
        ])
    }

    func compounds() throws -> Siblings<Compound> {
        return try siblings()
    }

    static func prepare(_ database: Fluent.Database) throws {
        try database.create(entity) { builder in
            builder.id()
            builder.string("name")
            builder.int("protons")
        }
    }
    static func revert(_ database: Fluent.Database) throws {
        try database.delete(entity)
    }
}
