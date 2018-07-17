import Fluent

extension Benchmarker where Database: QuerySupporting {
    private func _benchmarkStruct(on conn: Database.Connection) throws {
        start("Timestamp")
        var bar = Bar<Database>(baz: 1)
        if bar.createdAt != nil || bar.updatedAt != nil {
            fail("timestamps should be nil")
        }

        bar = try test(bar.save(on: conn))
        guard let originalCreatedAt = bar.createdAt, let originalUpdatedAt = bar.updatedAt else {
            fail("timestamps should exist after saving")
            return
        }
        if !originalCreatedAt.isWithin(seconds: 0.1, of: Date()) ||
           !originalUpdatedAt.isWithin(seconds: 0.1, of: Date()) {
            fail("timestamps should be current")
        }

        // Ensure that there is a substantial difference between `originalUpdatedAt` and `updatedAt`.
        Thread.sleep(forTimeInterval: 0.05)
        bar = try test(bar.save(on: conn))
        if bar.updatedAt! <= originalUpdatedAt {
            fail("new updated at should be greater")
        }

        let f = try test(Bar<Database>.self.query(on: conn).filter(\.baz == 1).first())
        guard let fetched = f else {
            fail("could not fetch bar")
            return
        }

        if !fetched.createdAt!.isWithin(seconds: 2, of: bar.createdAt!) ||
           !fetched.updatedAt!.isWithin(seconds: 2, of: bar.updatedAt!) {
            fail("fetched timestamps are >= 2ms different from expected according to model")
        }
    }

    private func _benchmarkClass(on conn: Database.Connection) throws {
        let tanner = User<Database>(name: "Tanner", age: 23)
        if tanner.createdAt != nil || tanner.updatedAt != nil {
            fail("timestamps should be nil")
        }

        _ = try test(tanner.save(on: conn))
        guard let originalCreatedAt = tanner.createdAt,
              let originalUpdatedAt = tanner.updatedAt else {
            fail("timestamps should exist after saving")
            return
        }
        if !originalCreatedAt.isWithin(seconds: 0.1, of: Date()) ||
           !originalUpdatedAt.isWithin(seconds: 0.1, of: Date()) {
            fail("timestamps should be current")
        }

        // Ensure that there is a substantial difference between `originalUpdatedAt` and `updatedAt`.
        Thread.sleep(forTimeInterval: 0.05)
        _ = try test(tanner.save(on: conn))
        if tanner.updatedAt! <= originalUpdatedAt {
            self.fail("new updated at should be greater")
        }

        let f = try test(User<Database>.query(on: conn).filter(\.name == "Tanner").first())
        guard let fetched = f else {
            self.fail("could not fetch user")
            return
        }

        if !fetched.createdAt!.isWithin(seconds: 2, of: tanner.createdAt!) ||
           !fetched.updatedAt!.isWithin(seconds: 2, of: tanner.updatedAt!) {
            fail("fetched timestamps are >= 2ms different from expected according to model")
        }
    }

    /// The actual benchmark.
    fileprivate func _benchmark(on conn: Database.Connection) throws {
        try _benchmarkStruct(on: conn)
        try _benchmarkClass(on: conn)
    }

    /// Benchmark the Timestampable protocol
    public func benchmarkTimestampable() throws {
        let conn = try test(pool.requestConnection())
        try self._benchmark(on: conn)
        pool.releaseConnection(conn)
    }
}

extension Benchmarker where Database: QuerySupporting & SchemaSupporting & MigrationSupporting {
    /// Benchmark the Timestampable protocol
    /// The schema will be prepared first.
    public func benchmarkTimestampable_withSchema() throws {
        let conn = try test(pool.requestConnection())
        try test(Bar<Database>.prepare(on: conn))
        try test(UserMigration<Database>.prepare(on: conn))
        defer {
            try? test(UserMigration<Database>.revert(on: conn))
            try? test(Bar<Database>.revert(on: conn))
        }
        try self._benchmark(on: conn)
        pool.releaseConnection(conn)
    }
}

extension Date {
    public func isWithin(seconds: Double, of other: Date) -> Bool {
        return abs(other.timeIntervalSince1970 - self.timeIntervalSince1970) <= seconds
    }

    public var unix: Int {
        return Int(timeIntervalSince1970)
    }
}
