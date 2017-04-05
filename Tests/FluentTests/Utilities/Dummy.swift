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
    var log: QueryLogCallback?
    
    var idType: IdentifierType = .int

    var idKey: String {
        return "foo"
    }

    enum Error: Swift.Error {
        case broken
    }
    
    public func makeConnection(_ type: ConnectionType) throws -> Connection {
        return DummyConnection()
    }
}

class DummyConnection: Connection {
    public var isClosed: Bool = false
    public var log: QueryLogCallback?

    func query<E: Entity>(_ query: RawOr<Query<E>>) throws -> Node {
        switch query {
        case .raw:
            return .array([])
        case .some(let query):
            if query.action == .count {
                return 0
            }
            
            return .array([])
        }
    }
}
