import Async
import Service
import Dispatch
import Fluent
import Foundation


final class BasicUser<D>:  Model where D: QuerySupporting {
    /// See Model.Database
    typealias Database = D

    /// See Model.ID
    typealias ID = Int

    /// See Model.idKey
    static var idKey: IDKey { return \.id }

    static var entity: String { return "b_users" }

    /// Foo's identifier
    var id: Int?

    /// Name string
    var name: String

    /// Creates a new `BasicUser`
    init(id: Int? = nil, name: String) {
        self.id = id
        self.name = name
    }
}

extension BasicUser: Migration where D: SchemaSupporting { }

extension Benchmarker where Database: QuerySupporting {
    /// The actual benchmark.
    fileprivate func _benchmark(on conn: Database.Connection) throws {
        let one = BasicUser<Database>(name: "one")
        let two = BasicUser<Database>(name: "two")

        let res = try test([
            one.save(on: conn),
            two.save(on: conn)
        ].flatten(on: conn))
        print(one.id)
        print(two.id)
    }

    /// Benchmark the Timestampable protocol
    public func benchmarkBugs() throws {
        let conn = try test(pool.requestConnection())
        try self._benchmark(on: conn)
        pool.releaseConnection(conn)
    }
}

extension Benchmarker where Database: QuerySupporting & SchemaSupporting {
    /// Benchmark the Timestampable protocol
    /// The schema will be prepared first.
    public func benchmarkBugs_withSchema() throws {
        let conn = try test(pool.requestConnection())
        try? test(BasicUser<Database>.revert(on: conn))
        try test(BasicUser<Database>.prepare(on: conn))
        defer { try? test(BasicUser<Database>.revert(on: conn)) }
        try self._benchmark(on: conn)
        pool.releaseConnection(conn)
    }
}
