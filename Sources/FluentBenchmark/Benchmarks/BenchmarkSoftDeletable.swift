import Fluent

extension Benchmarker where Database: QuerySupporting & TransactionSupporting {
    /// The actual benchmark.
    fileprivate func _benchmark(on conn: Database.Connection) throws {
        // create
        var bar = Bar<Database>(baz: 1)

        if try test(Bar<Database>.query(on: conn).count()) != 0 {
            fail("count should have been 0")
        }

        bar = try test(bar.save(on: conn))
        if try test(Bar<Database>.query(on: conn).count()) != 1 {
            fail("count should have been 1")
        }
        if try test(Bar<Database>.query(on: conn, withSoftDeleted: true).count()) != 1 {
            fail("count should have been 1")
        }

        try test(bar.delete(on: conn))
        if try test(Bar<Database>.query(on: conn).count()) != 0 {
            fail("count should have been 0")
        }
        if try test(Bar<Database>.query(on: conn, withSoftDeleted: true).count()) != 1 {
            fail("count should have been 1")
        }

        bar = try test(bar.restore(on: conn))
        if try test(Bar<Database>.query(on: conn).count()) != 1 {
            fail("count should have been 1")
        }
        if try test(Bar<Database>.query(on: conn, withSoftDeleted: true).count()) != 1 {
            fail("count should have been 1")
        }

        try test(bar.delete(force: true, on: conn))
        if try test(Bar<Database>.query(on: conn).count()) != 0 {
            fail("count should have been 0")
        }
        if try test(Bar<Database>.query(on: conn, withSoftDeleted: true).count()) != 0 {
            fail("count should have been 0")
        }
    }

    /// Benchmark fluent transactions.
    public func benchmarkSoftDeletable() throws {
        let conn = try test(pool.requestConnection())
        try self._benchmark(on: conn)
        pool.releaseConnection(conn)
    }
}

extension Benchmarker where Database: QuerySupporting & TransactionSupporting & SchemaSupporting & MigrationSupporting {
    /// Benchmark fluent transactions.
    /// The schema will be prepared first.
    public func benchmarkSoftDeletable_withSchema() throws {
        let conn = try test(pool.requestConnection())
        try test(Bar<Database>.prepare(on: conn))
        defer {
            try? test(Bar<Database>.revert(on: conn))
        }
        try self._benchmark(on: conn)
        pool.releaseConnection(conn)
    }
}


