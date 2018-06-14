import Fluent

extension Benchmarker where Database: QuerySupporting {
    /// The actual benchmark.
    fileprivate func _benchmark(on conn: Database.Connection) throws {
        var message = LogMessage<Database>(message: "hello")

        if message.id != nil {
            fail("message ID was incorrectly set")
        }

        message = try test(message.save(on: conn))
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

extension Benchmarker where Database: QuerySupporting & SchemaSupporting & MigrationSupporting {
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
