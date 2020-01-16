import Fluent

extension DatabaseID {
    static var test: DatabaseID { .init(string: "test") }
}

struct TestDatabase: Database {
    let driver: TestDatabaseDriver
    let context: DatabaseContext

    func execute(query: DatabaseQuery, onRow: @escaping (DatabaseRow) -> ()) -> EventLoopFuture<Void> {
        self.driver.handler(query).forEach(onRow)
        return self.eventLoop.makeSucceededFuture(())
    }

    func execute(schema: DatabaseSchema) -> EventLoopFuture<Void> {
        fatalError()
    }

    func withConnection<T>(_ closure: @escaping (Database) -> EventLoopFuture<T>) -> EventLoopFuture<T> {
        closure(self)
    }
}

struct TestRow: DatabaseRow {
    var data: [String: Any]

    var description: String {
        self.data.description
    }

    func contains(field: String) -> Bool {
        self.data.keys.contains(field)
    }

    func decode<T>(field: String, as type: T.Type, for database: Database) throws -> T where T : Decodable {
        return self.data[field] as! T
    }
}

final class TestDatabaseDriver: DatabaseDriver {
    let handler: (DatabaseQuery) -> [DatabaseRow]

    init(_ handler: @escaping (DatabaseQuery) -> [DatabaseRow]) {
        self.handler = handler
    }

    func makeDatabase(with context: DatabaseContext) -> Database {
        TestDatabase(driver: self, context: context)
    }

    func shutdown() {
        // nothing
    }
}
