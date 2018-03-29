import Async
import Service
import Dispatch
import Fluent
import Foundation

extension Benchmarker where Database: QuerySupporting {
    /// Benchmarking pipelining saves.
    fileprivate func _benchmarkPipelining(on conn: Database.Connection) throws {
        let one = BasicUser<Database>(name: "one")
        let two = BasicUser<Database>(name: "two")
        let three = BasicUser<Database>(name: "three")

        _ = try test([
            one.save(on: conn),
            two.save(on: conn),
            three.save(on: conn),
        ].flatten(on: conn))
        if one.id == two.id || one.id == three.id || two.id == three.id {
            fail("ids are equal")
        }
    }

    /// Benchmarking save nil
    fileprivate func _benchmarkNilUpdate(on conn: Database.Connection) throws {
        var one = BasicUser<Database>(name: "one")
        one = try test(one.save(on: conn))
        if one.name == nil {
            fail("name is nil")
        }
        one.name = nil
        one = try test(one.save(on: conn))

        if let fetched = try test(BasicUser<Database>.find(one.requireID(), on: conn)) {
            if fetched.name != nil {
                fail("name is not nil")
            }
        } else {
            fail("could not fetch")
        }
    }

    fileprivate func _benchmark(on conn: Database.Connection) throws {
        try self._benchmarkPipelining(on: conn)
        try self._benchmarkNilUpdate(on: conn)
    }

    /// Benchmarks misc bugs
    public func benchmarkBugs() throws {
        let conn = try test(pool.requestConnection())
        try self._benchmark(on: conn)
        pool.releaseConnection(conn)
    }
}

extension Benchmarker where Database: QuerySupporting & SchemaSupporting {
    /// Benchmarks misc bugs, preparing the schema first.
    public func benchmarkBugs_withSchema() throws {
        let conn = try test(pool.requestConnection())
        try test(BasicUser<Database>.prepare(on: conn))
        defer { try? test(BasicUser<Database>.revert(on: conn)) }
        try self._benchmark(on: conn)
        pool.releaseConnection(conn)
    }
}

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
    var name: String?

    /// Creates a new `BasicUser`
    init(id: Int? = nil, name: String?) {
        self.id = id
        self.name = name
    }
}

extension BasicUser: Migration where D: SchemaSupporting { }
