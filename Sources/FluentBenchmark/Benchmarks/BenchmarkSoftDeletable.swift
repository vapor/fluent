import Fluent

extension Benchmarker where Database: QuerySupporting & TransactionSupporting {
    /// The actual benchmark.
    fileprivate func _benchmark(on conn: Database.Connection) throws {
        start("Soft delete")
        var bar1 = Bar<Database>(baz: 1)
        var bar2 = Bar<Database>(baz: 2)

        // Initially empty
        if try test(Bar<Database>.query(on: conn).count()) != 0 {
            fail("count should have been 0")
        }

        // Create two rows
        bar1 = try test(bar1.save(on: conn))
        bar2 = try test(bar2.save(on: conn))
        if try test(Bar<Database>.query(on: conn).count()) != 2 {
            fail("count should have been 2")
        }
        if try test(Bar<Database>.query(on: conn, withSoftDeleted: true).count()) != 2 {
            fail("count should have been 2")
        }

        // Soft delete the first
        try test(bar1.delete(on: conn))
        if try test(Bar<Database>.query(on: conn).count()) != 1 {
            fail("count should have been 1")
        }
        if try test(Bar<Database>.query(on: conn, withSoftDeleted: true).count()) != 2 {
            fail("count should have been 2")
        }

        // Soft delete the second
        try test(bar2.delete(on: conn))
        if try test(Bar<Database>.query(on: conn).count()) != 0 {
            fail("count should have been 0")
        }
        if try test(Bar<Database>.query(on: conn, withSoftDeleted: true).count()) != 2 {
            fail("count should have been 2")
        }
        
        // Restore the first
        bar1 = try test(bar1.restore(on: conn))
        if try test(Bar<Database>.query(on: conn).count()) != 1 {
            fail("count should have been 1")
        }
        if try test(Bar<Database>.query(on: conn, withSoftDeleted: true).count()) != 2 {
            fail("count should have been 2")
        }

        // Delete both
        try test(bar1.delete(force: true, on: conn))
        if try test(Bar<Database>.query(on: conn).count()) != 0 {
            fail("count should have been 0")
        }
        if try test(Bar<Database>.query(on: conn, withSoftDeleted: true).count()) != 1 {
            fail("count should have been 1")
        }
        try test(bar2.delete(force: true, on: conn))
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


