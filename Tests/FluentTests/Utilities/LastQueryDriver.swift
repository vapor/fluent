import Fluent

class LastQueryDriver: Driver {
    var idKey: String = "#id"

    var lastQuery: SQL?
    var lastSchema: Schema?
    var lastRaw: (String, [Node])?

    @discardableResult
    func query<T: Entity>(_ query: Query<T>) throws -> Node {
        let sql = query.sql
        lastQuery = sql
        print("[LQD] \(sql)")
        return Node.object([idKey: 5])
    }

    func schema(_ schema: Schema) throws {
        lastSchema = schema
    }

    func raw(_ raw: String, _ values: [Node]) throws -> Node {
        lastRaw = (raw, values)
        return .null
    }
}
