import Fluent
import Testing
import Vapor
import VaporTesting

@Suite
struct OperatorTests {
    @Test
    func customOperators() throws {
        // TODO: What does this test...?
        let db = DummyDatabase()

        // name contains string anywhere, prefix, suffix
        _ = Planet.query(on: db)
            .filter(\.$name ~~ "art")
        _ = Planet.query(on: db)
            .filter(\.$name =~ "art")
        _ = Planet.query(on: db)
            .filter(\.$name ~= "art")
        // name doesn't contain string anywhere, prefix, suffix
        _ = Planet.query(on: db)
            .filter(\.$name !~ "art")
        _ = Planet.query(on: db)
            .filter(\.$name !=~ "art")
        _ = Planet.query(on: db)
            .filter(\.$name !~= "art")

        // name in array
        _ = Planet.query(on: db)
            .filter(\.$name ~~ ["Earth", "Mars"])
        // name not in array
        _ = Planet.query(on: db)
            .filter(\.$name !~ ["Earth", "Mars"])
    }
}

private final class Planet: Model, @unchecked Sendable {
    static let schema = "planets"

    @ID(custom: .id)
    var id: Int?

    @Field(key: "name")
    var name: String
}

private struct DummyDatabase: Database {
    var inTransaction: Bool {
        false
    }

    var context: DatabaseContext {
        .init(configuration: DummyDatabaseConfiguration(), logger: Logger(label: "fluent"), eventLoop: MultiThreadedEventLoopGroup.singleton.any())
    }

    func execute(query: DatabaseQuery, onOutput: @escaping @Sendable (any DatabaseOutput) -> Void) -> EventLoopFuture<Void> {
        fatalError()
    }

    func execute(schema: DatabaseSchema) -> EventLoopFuture<Void> {
        fatalError()
    }

    func execute(enum: DatabaseEnum) -> EventLoopFuture<Void> {
        fatalError()
    }

    func withConnection<T>(_ closure: @escaping @Sendable (any Database) -> EventLoopFuture<T>) -> EventLoopFuture<T> {
        fatalError()
    }

    func transaction<T>(_ closure: @escaping @Sendable (any Database) -> EventLoopFuture<T>) -> EventLoopFuture<T> {
        fatalError()
    }
}

private struct DummyDatabaseConfiguration: DatabaseConfiguration {
    var middleware: [any FluentKit.AnyModelMiddleware] = []

    func makeDriver(for databases: FluentKit.Databases) -> any FluentKit.DatabaseDriver {
        DummyDatabaseDriver()
    }
}

private struct DummyDatabaseDriver: DatabaseDriver {
    func makeDatabase(with context: FluentKit.DatabaseContext) -> any FluentKit.Database {
        DummyDatabase()
    }
    
    func shutdown() {}
}
