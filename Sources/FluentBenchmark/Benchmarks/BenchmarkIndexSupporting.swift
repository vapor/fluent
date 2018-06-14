import Fluent

extension Benchmarker where Database: SchemaSupporting & MigrationSupporting {
    /// The actual benchmark.
    fileprivate func _benchmark(on conn: Database.Connection) throws {
        var a1 = IndexSupportingModel<Database>(name: "a", age: 1)
        a1 = try test(a1.save(on: conn))
        var a2 = IndexSupportingModel<Database>(name: "a", age: 2)
        a2 = try test(a2.save(on: conn))
        do {
            var a1Duplicate = IndexSupportingModel<Database>(name: "a", age: 1)
            a1Duplicate = try a1Duplicate.save(on: conn).wait()
            fail("should not have saved")
        } catch {
            // pass
        }
    }

    /// Benchmark fluent relations.
    public func benchmarkIndexSupporting() throws {
        let conn = try test(pool.requestConnection())
        try self._benchmark(on: conn)
        self.pool.releaseConnection(conn)
    }
}

extension Benchmarker where Database: SchemaSupporting & MigrationSupporting {
    /// Benchmark fluent relations.
    /// The schema will be prepared first.
    public func benchmarkIndexSupporting_withSchema() throws {
        let conn = try test(pool.requestConnection())
        try test(IndexSupportingModel<Database>.prepare(on: conn))
        defer {
            try? test(IndexSupportingModel<Database>.revert(on: conn))
        }

        try self._benchmark(on: conn)
        self.pool.releaseConnection(conn)
    }
}
