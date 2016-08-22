import Fluent

final class Atom: Entity {
    var id: Node?
    var name: String
    var groupId: Node?

    init(name: String) {
        id = nil
        self.name = name
    }

    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        name = try node.extract("name")
        groupId = try node.extract("group_id")
    }

    func makeNode() throws -> Node {
        return try Node(node: [
            "id": id,
            "name": name,
            "group": try group().get()
        ])
    }

    func compounds() throws -> Siblings<Compound> {
        return try siblings()
    }

    func group() throws -> Parent<Group> {
        return try parent(groupId)
    }

    func protons() throws -> Children<Proton> {
        return children()
    }

    func nucleus() throws -> Nucleus? {
        return try children().first()
    }

    static func prepare(_ database: Fluent.Database) throws {
        try database.create(entity) { builder in
            builder.id()
            builder.string("name")
            builder.int("group_id")
        }
    }
    static func revert(_ database: Fluent.Database) throws {
        try database.delete(entity)
    }
}
