import Fluent

final class DummyModel: Entity {
    static var entity: String {
        return "dummy_models"
    }

    var id: Node?

    func makeNode() -> Node {
        return .null
    }

    init(node: Node, in context: Context) throws {

    }

    static func prepare(_ database: Database) throws {}
    static func revert(_ database: Database) throws {}
}

class DummyDriver: Driver {
    var idKey: String {
        return "foo"
    }

    enum Error: Swift.Error {
        case broken
    }

    func query<T: Entity>(_ query: Query<T>) throws -> Node {
        return .array([])
    }

    func schema(_ schema: Schema) throws {

    }

    func raw(_ raw: String, _ values: [Node]) throws -> Node {
        return .null
    }
}
