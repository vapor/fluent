import Fluent

class LastQueryDriver: Driver {
    var keyNamingConvention: KeyNamingConvention = .snake_case
    var idType: IdentifierType = .int
    var idKey: String = "#id"

    var lastQuery: (String, [Node])?
    var lastRaw: (String, [Node])?
    
    func makeConnection() throws -> Connection {
        return LastQueryConnection(driver: self)
    }
}

struct LastQueryConnection: Connection {
    public var closed: Bool = false
    
    var driver: LastQueryDriver
    
    init(driver: LastQueryDriver) {
        self.driver = driver
    }
    
    @discardableResult
    func query<E: Entity>(_ query: Query<E>) throws -> Node {
        let serializer = GeneralSQLSerializer(query)
        driver.lastQuery = serializer.serialize()
        return try Node(node: [
            [
                E.idKey: 5
            ]
        ], in: nil)
    }

    func raw(_ raw: String, _ values: [Node]) throws -> Node {
        driver.lastRaw = (raw, values)
        return .null
    }
}
