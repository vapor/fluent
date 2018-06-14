extension Benchmarker where Database: QuerySupporting {
    /// The actual benchmark.
    fileprivate func _benchmark(on conn: Database.Connection) throws {
        // create
        let a = Foo<Database>(bar: "asdf", baz: 42)
        let b = Foo<Database>(bar: "asdf", baz: 42)
        
        _ = try test(a.save(on: conn))
        _ = try test(b.save(on: conn))
        var count = try test(Foo<Database>.query(on: conn).count())
        if count != 2 {
            self.fail("count should have been 2")
        }

        // update
        b.bar = "fdsa"
        _ = try test(b.save(on: conn))
        _ = try test(Foo.query(on: conn).filter(\Foo<Database>.id == a.id).update(data: ["baz": 314]))

        // read
        let fetched = try test(Foo<Database>.find(b.requireID(), on: conn))
        if fetched?.bar != "fdsa" {
            self.fail("b.bar should have been updated")
        }

        // make sure that AND queries work as expected - this query should return exactly one result
        let fetchedWithAndQuery = try test(Foo<Database>.query(on: conn)
            .group(Database.queryFilterRelationAnd) { and in
                and.filter(\Foo.bar == "asdf")
                and.filter(\Foo.baz == 314)
            }
            .all())
        if fetchedWithAndQuery.count != 1 {
            self.fail("fetchedWithAndQuery.count = \(fetchedWithAndQuery.count), should be 1")
        }

        // make sure that OR queries work as expected - this query should return exactly two results
        let fetchedWithOrQuery = try test(Foo<Database>.query(on: conn)
            .group(Database.queryFilterRelationOr) { or in
                or.filter(\Foo.bar == "asdf")
                or.filter(\Foo.bar == "fdsa")
            }
            .all())
        if fetchedWithOrQuery.count != 2 {
            self.fail("fetchedWithOrQuery.count = \(fetchedWithOrQuery.count), should be 2")
        }

        try test(b.delete(on: conn))
        count = try test(Foo<Database>.query(on: conn).count())
        if count != 1 {
            self.fail("count should have been 1")
        }
    }

    /// Benchmark the basic model CRUD.
    public func benchmarkModels() throws {
        let conn = try test(pool.requestConnection())
        try self._benchmark(on: conn)
        pool.releaseConnection(conn)
    }
}

extension Benchmarker where Database: QuerySupporting & SchemaSupporting & MigrationSupporting {
    /// Benchmark the basic model CRUD.
    /// The schema will be prepared first.
    public func benchmarkModels_withSchema() throws {
        let conn = try test(pool.requestConnection())
        try test(FooMigration<Database>.prepare(on: conn))
        defer { try? test(FooMigration<Database>.revert(on: conn)) }
        try self._benchmark(on: conn)
        pool.releaseConnection(conn)
    }
}
