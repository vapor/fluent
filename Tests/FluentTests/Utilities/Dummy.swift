import Fluent

final class DummyModel: Entity {
    let storage = Storage()
    static var entity: String {
        return "dummy_models"
    }

    init(row: Row) {}
    func makeRow() -> Row { return .null}
}

class DummyDriver: Driver {
    var keyNamingConvention: KeyNamingConvention = .snake_case
    
    var idType: IdentifierType = .int

    var idKey: String {
        return "foo"
    }

    enum Error: Swift.Error {
        case broken
    }
    
    func makeConnection() throws -> Connection {
        return DummyConnection()
    }
}

class DummyConnection: Connection {
    public var isClosed: Bool = false

    func query<E: Entity>(_ query: Query<E>) throws -> Node {
        if query.action == .count {
            return 0
        }
        
        return .array([])
    }

    func raw(_ raw: String, _ values: [Node]) throws -> Node {
        return .null
    }
}
