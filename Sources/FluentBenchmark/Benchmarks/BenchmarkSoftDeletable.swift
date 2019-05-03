import Fluent

extension Benchmarker where Database: QuerySupporting & TransactionSupporting {
    /// The actual benchmark.
    fileprivate func _benchmarkBasicFunctionality(on conn: Database.Connection) throws {
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

    /// Verify that updatedAt and deletedAt are changed appropriately for soft delete.
    fileprivate func _benchmarkTimestamps(on conn: Database.Connection) throws {
        start("Soft delete timestamps")

        // Initially empty
        if try test(Bar<Database>.query(on: conn).count()) != 0 {
            fail("count should have been 0")
        }

        // Upon creation, updatedAt should be set and deletedAt should be nil
        var bar = Bar<Database>(baz: 16)
        bar = try test(bar.save(on: conn))
        if bar.deletedAt != nil {
            fail("deletedAt should not be set")
        }
        guard let updatedAtAfterCreate = bar.updatedAt else {
            fail("updatedAt was not set")
            return
        }
        
        // Ensure that there is a substantial difference for checking update timestamp.
        Thread.sleep(forTimeInterval: 0.05)

        // After soft delete, updatedAt should have changed and deletedAt should now be set
        try test(bar.delete(on: conn))
        guard let deletedBar = try test(Bar<Database>.query(on: conn, withSoftDeleted: true).first()) else {
            fail("hard delete when soft was expected")
            return
        }
        bar = deletedBar
        guard let deletedAt = bar.deletedAt else {
            fail("deletedAt was not set")
            return
        }
        if !deletedAt.isWithin(seconds: 0.1, of: Date()) {
            fail("timestamps should be current")
        }
        if deletedAt <= updatedAtAfterCreate {
            fail("deletedAt value is invalid")
        }
        guard let updatedAtAfterDelete = bar.updatedAt else {
            fail("updatedAt was cleared after soft delete")
            return
        }
        if updatedAtAfterDelete <= updatedAtAfterCreate {
            fail("updatedAt was not changed after soft delete")
        }

        // Ensure that there is a substantial difference for checking update timestamp.
        Thread.sleep(forTimeInterval: 0.05)

        // After reset, updatedAt should have changed and deletedAt should now be nil
        bar = try test(bar.restore(on: conn))
        if bar.deletedAt != nil {
            fail("deletedAt was not cleared after restore")
        }
        if bar.updatedAt == nil {
            fail("updateAt was cleared after restore")
        }
        guard let updatedAtAfterRestore = bar.updatedAt else {
            fail("updatedAt was cleared after restore")
            return
        }
        if updatedAtAfterRestore <= updatedAtAfterDelete {
            fail("updatedAt was not changed after restore")
        }

        // Clean up
        try test(Bar<Database>.query(on: conn, withSoftDeleted: true).delete(force: true))
        if try test(Bar<Database>.query(on: conn).count()) != 0 {
            fail("count should be 0 at the end of the test")
        }
    }

    /// The actual benchmark.
    fileprivate func _benchmark(on conn: Database.Connection) throws {
        try _benchmarkBasicFunctionality(on: conn)
        try _benchmarkTimestamps(on: conn)
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
