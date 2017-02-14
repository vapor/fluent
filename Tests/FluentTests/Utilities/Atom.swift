import Fluent

final class Atom: Entity {
    var name: String
    var groupId: Node
    let storage = Storage()

    init(name: String, id: Node? = nil) {
        self.name = name
        self.groupId = 0
        self.set(id: id)
    }

    init(node: Node, in context: Context) throws {
        name = try node.extract("name")
        groupId = try node.extract("group_id")

        id(with: node)
    }

    func makeNode(context: Context = EmptyNode) throws -> Node {
        return try Node(node: [
            type(of: self).idKey: id,
            "name": name,
            "group_id": groupId
        ])
    }

    func compounds() throws -> Siblings<Atom, Compound> {
        return try siblings()
    }

    func group() throws -> Parent<Atom, Group> {
        return try parent(id: groupId)
    }

    func protons() throws -> Children<Atom, Proton> {
        return try children()
    }

    func nucleus() throws -> Nucleus? {
        return try children().first()
    }

    static func prepare(_ database: Fluent.Database) throws {
        try database.create(entity) { builder in
            builder.id(for: self)
            builder.string("name")
            builder.int("group_id")
        }
    }
    static func revert(_ database: Fluent.Database) throws {
        try database.delete(entity)
    }

    // MARK: Callbacks

    func willCreate() {
        print("Atom will create.")
    }

    func didCreate() {
        print("Atom did create.")
    }

    func willUpdate() {
        print("Atom will update.")
    }

    func didUpdate() {
        print("Atom did update.")
    }

    func willDelete() {
        print("Atom will delete.")
    }

    func didDelete() {
        print("Atom did delete.")
    }
}
