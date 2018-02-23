import Async
import Service
import Dispatch
import Fluent
import Foundation

extension Benchmarker where Database: QuerySupporting {
    /// The actual benchmark.
    fileprivate func _benchmark(on conn: Database.Connection) throws {
        let message = LogMessage<Database>(message: "hello")

        if message.id != nil {
            fail("message ID was incorrectly set")
        }

        _ = try test(message.save(on: conn))
        if message.id == nil {
            fail("message ID was not set")
        }
    }

    /// Benchmark the Timestampable protocol
    public func benchmarkAutoincrement() throws {
        let conn = try test(pool.requestConnection())
        try self._benchmark(on: conn)
        pool.releaseConnection(conn)
    }
}

extension Benchmarker where Database: QuerySupporting & SchemaSupporting {
    /// Benchmark the Timestampable protocol
    /// The schema will be prepared first.
    public func benchmarkAutoincrement_withSchema() throws {
        let conn = try test(pool.requestConnection())
        try test(LogMessageMigration<Database>.prepare(on: conn))
        defer {
            try? test(LogMessageMigration<Database>.revert(on: conn))
        }
        try self._benchmark(on: conn)
        pool.releaseConnection(conn)
    }
}
