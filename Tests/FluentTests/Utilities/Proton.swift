import Fluent

final class Proton: Entity {
    let storage = Storage()
    init(node: Node) throws {}

    func makeNode(in context: Context?) -> Node { return .null }
    static func prepare(_ database: Database) throws {
        try database.create(self) { protons in
            protons.id(for: self)
            protons.foreignId(for: Atom.self)
        }
    }
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}
