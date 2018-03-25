import Async
import Dispatch
import Fluent
import FluentSQL
import Foundation

extension Benchmarker where Database: QuerySupporting, Database.QueryFilter: DataPredicateComparisonConvertible {
    /// The actual benchmark.
    fileprivate func _benchmark(on conn: Database.Connection) throws {
        // create
        let tanner1 = User<Database>(name: "tanner", age: 23)
        _ = try test(tanner1.save(on: conn))
        let tanner2 = User<Database>(name: "ner", age: 23)
        _ = try test(tanner2.save(on: conn))
        let tanner3 = User<Database>(name: "tan", age: 23)
        _ = try test(tanner3.save(on: conn))

        let tas = try test(User<Database>.query(on: conn).filter(\.name =~ "ta").count())
        if tas != 2 {
            fail("tas == \(tas)")
        }
        let ers = try test(User<Database>.query(on: conn).filter(\.name ~= "er").count())
        if ers != 2 {
            fail("ers == \(tas)")
        }
        let annes = try test(User<Database>.query(on: conn).filter(\.name ~~ "anne").count())
        if annes != 1 {
            fail("annes == \(tas)")
        }
        let ns = try test(User<Database>.query(on: conn).filter(\.name ~~ "n").count())
        if ns != 3 {
            fail("ns == \(tas)")
        }

        let nertan = try test(User<Database>.query(on: conn).filter(\.name ~~ ["ner", "tan"]).count())
        if nertan != 2 {
            fail("nertan == \(tas)")
        }

        let notner = try test(User<Database>.query(on: conn).filter(\.name !~ ["ner"]).count())
        if notner != 2 {
            fail("nertan == \(tas)")
        }
    }

    /// Benchmark fluent contains.
    public func benchmarkContains() throws {
        let conn = try test(pool.requestConnection())
        try self._benchmark(on: conn)
        pool.releaseConnection(conn)
    }
}

extension Benchmarker where Database: QuerySupporting & SchemaSupporting, Database.QueryFilter: DataPredicateComparisonConvertible {
    /// Benchmark fluent contains. The schema will be prepared first.
    public func benchmarkContains_withSchema() throws {
        let conn = try test(pool.requestConnection())
        try test(UserMigration<Database>.prepare(on: conn))
        defer {
            try? test(UserMigration<Database>.revert(on: conn))
        }
        try self._benchmark(on: conn)
        pool.releaseConnection(conn)
    }
}
