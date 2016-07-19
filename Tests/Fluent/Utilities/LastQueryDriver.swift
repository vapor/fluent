import Fluent

class LastQueryDriver: Driver {
    var idKey: String = "#id"

    var lastQuery: SQL?
    var lastSchema: Schema?

    @discardableResult
    func query<T: Entity>(_ query: Query<T>) throws -> Node {
        let sql = query.sql
        lastQuery = sql
        print("[LQD] \(sql)")
        return .null
    }

    func schema(_ schema: Schema) throws {
        lastSchema = schema
    }
}
