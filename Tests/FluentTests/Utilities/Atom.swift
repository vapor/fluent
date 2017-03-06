import Fluent

final class Atom: Entity {
    var name: String
    var groupId: Node
    let storage = Storage()

    init(name: String, id: Node? = nil) {
        self.name = name
        self.groupId = 0
        self.id = id
    }

    init(node: Node) throws {
        name = try node.get("name")
        groupId = try node.get("group_id")

        id = try node.get(idKey)
    }

    func makeNode(in context: Context?) throws -> Node {
        return try Node(node: [
            idKey: id,
            "name": name,
            "group_id": groupId
        ])
    }

    var compounds: Siblings<Atom, Compound, Pivot<Atom, Compound>> {
        return siblings()
    }

    func group() throws -> Parent<Atom, Group> {
        return parent(id: groupId)
    }

    func protons() throws -> Children<Atom, Proton> {
        return children()
    }

    func nucleus() throws -> Nucleus? {
        return try children().first()
    }

    static func prepare(_ database: Fluent.Database) throws {
        try database.create(self) { builder in
            builder.id(for: self)
            builder.string("name")
            builder.int("group_id")
        }
    }
    static func revert(_ database: Fluent.Database) throws {
        try database.delete(self)
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
