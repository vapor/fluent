import Fluent

class LastQueryDriver: Driver {
    var idType: IdentifierType = .int
    var idKey: String = "#id"

    var lastQuery: SQL?
    var lastSchema: Schema?
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
    func query<T: Entity>(_ query: Query<T>) throws -> Node {
        let sql = query.sql
        driver.lastQuery = sql
        print("[LQD] \(sql)")
        return Node.object([T.idKey: 5])
    }

    func schema(_ schema: Schema) throws {
        driver.lastSchema = schema
    }

    func raw(_ raw: String, _ values: [Node]) throws -> Node {
        driver.lastRaw = (raw, values)
        return .null
    }
}
