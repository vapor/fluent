final class Migration: Entity {
    static var entity = "fluent"

    var id: Node?
    var name: String

    init(name: String) {
        self.name = name
    }

    init(_ node: Node) throws {
        id = try node.extract("id")
        name = try node.extract("name")
    }
}
