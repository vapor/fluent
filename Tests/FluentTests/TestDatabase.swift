import Fluent

extension DatabaseID {
    static var test: DatabaseID { .init(string: "test") }
}

struct TestDatabase: Database {
    let driver: TestDatabaseDriver
    let context: DatabaseContext

    func execute(query: DatabaseQuery, onOutput: @escaping (DatabaseOutput) -> ()) -> EventLoopFuture<Void> {
        self.driver.handler(query).forEach(onOutput)
        return self.eventLoop.makeSucceededFuture(())
    }

    func execute(schema: DatabaseSchema) -> EventLoopFuture<Void> {
        fatalError()
    }
    
    func execute(enum: DatabaseEnum) -> EventLoopFuture<Void> {
        fatalError()
    }
    
    func withConnection<T>(_ closure: @escaping (Database) -> EventLoopFuture<T>) -> EventLoopFuture<T> {
        closure(self)
    }

    func transaction<T>(_ closure: @escaping (Database) -> EventLoopFuture<T>) -> EventLoopFuture<T> {
        closure(self)
    }
}

struct TestRow: DatabaseOutput {
    var data: [FieldKey: Any]

    var description: String {
        self.data.description
    }
    
    func schema(_ schema: String) -> DatabaseOutput {
        self
    }

    func contains(_ field: FieldKey) -> Bool {
        self.data.keys.contains(field)
    }

    func decode<T>(_ field: FieldKey, as type: T.Type) throws -> T where T : Decodable {
        self.data[field]! as! T
    }
}

final class TestDatabaseDriver: DatabaseDriver {
    let handler: (DatabaseQuery) -> [DatabaseOutput]

    init(_ handler: @escaping (DatabaseQuery) -> [DatabaseOutput]) {
        self.handler = handler
    }

    func makeDatabase(with context: DatabaseContext) -> Database {
        TestDatabase(driver: self, context: context)
    }

    func shutdown() {
        // nothing
    }
}

struct TestDatabaseConfiguration: DatabaseConfiguration {
    let handler: (DatabaseQuery) -> [DatabaseOutput]

    var middleware: [AnyModelMiddleware] = []

    func makeDriver(for databases: Databases) -> DatabaseDriver {
        TestDatabaseDriver(handler)
    }
}
