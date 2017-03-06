import Fluent

final class Nucleus: Entity {
    let storage = Storage()
    static var entity = "nuclei"

    init(node: Node) throws { }

    func makeNode(in context: Context?) -> Node { return .null }
    static func prepare(_ database: Database) throws {
        try database.create(self) { nuclei in
            nuclei.id(for: self)
            nuclei.foreignId(for: Atom.self)
        }
    }
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}
