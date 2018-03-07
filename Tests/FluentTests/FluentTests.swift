import Async
import Fluent
import FluentBenchmark
import FluentSQL
import XCTest

final class FluentTests: XCTestCase {
    func testCustomSQLSyntax() throws {
        FakeModel.query(on: FakeConnection()).customSQL { sql in
            let predicate = DataPredicate.init(column: .init(name: "createdAt"), comparison: .greaterThan, value: .custom("DATE()"))
            sql.predicates.append(.predicate(predicate))
        }.filter(\.id == "five")
    }

    static let allTests = [
        ("testCustomSQLSyntax", testCustomSQLSyntax),
    ]
}

/// MARK: Utils

final class FakeModel: Model {
    static var idKey: WritableKeyPath<FakeModel, String?> = \.id
    typealias Database = FakeDatabase
    typealias ID = String
    var id: String?
}

final class FakeDatabase: QuerySupporting {
    typealias QueryData = String
    typealias Connection = FakeConnection

    static func execute(
        query: DatabaseQuery<FakeDatabase>,
        into handler: @escaping ([QueryField : String], FakeConnection) throws -> (),
        on connection: FakeConnection
    ) -> EventLoopFuture<Void> {
        fatalError()
    }

    static func modelEvent<M>(event: ModelEvent, model: M, on connection: FakeConnection) -> EventLoopFuture<M> where FakeDatabase == M.Database, M : Model {
        fatalError()
    }

    static func queryDataSerialize<T>(data: T?) throws -> String {
        fatalError()
    }

    static func queryDataParse<T>(_ type: T.Type, from data: String) throws -> T {
        fatalError()
    }

    func makeConnection(on worker: Worker) -> EventLoopFuture<FakeConnection> {
        fatalError()
    }
}

extension FakeDatabase: CustomSQLSupporting { }

final class FakeConnection: DatabaseConnection {
    init() { }

    func shutdownGracefully(queue: DispatchQueue, _ callback: @escaping (Error?) -> Void) {
        fatalError()
    }

    func close() {
        fatalError()
    }

    func next() -> EventLoop {
        return EmbeddedEventLoop()
    }
}
