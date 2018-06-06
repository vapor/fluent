import Fluent

extension Benchmarker where Database: JoinSupporting & QuerySupporting {
    /// The actual benchmark.
    fileprivate func _benchmark(on conn: Database.Connection) throws {
        // create
        let tanner = User<Database>(name: "Tanner", age: 23)
        _ = try test(tanner.save(on: conn))

        let ziz = try Pet<Database>(name: "Ziz", ownerID: tanner.requireID())
        _ = try test(ziz.save(on: conn))

        let pets = try test(Pet<Database>.query(on: conn).join(\User<Database>.id, to: \Pet<Database>.ownerID).all())
        if pets.count != 1 {
            fail("pet count \(pets.count) != 1")
        }

        let owners = try test(User<Database>.query(on: conn).join(\Pet<Database>.ownerID, to: \User<Database>.id).all())
        if owners.count != 1 {
            fail("owner count \(owners.count) != 1")
        }
    }

    /// Benchmark fluent relations.
    public func benchmarkJoins() throws {
        let conn = try test(pool.requestConnection())
        try self._benchmark(on: conn)
        self.pool.releaseConnection(conn)
    }
}

extension Benchmarker where Database: SchemaSupporting & MigrationSupporting & JoinSupporting {
    /// Benchmark fluent relations.
    /// The schema will be prepared first.
    public func benchmarkJoins_withSchema() throws {
        let conn = try test(pool.requestConnection())
        try test(Database.enableReferences(on: conn))

        try test(UserMigration<Database>.prepare(on: conn))
        try test(Pet<Database>.prepare(on: conn))
        defer {
            try? test(Pet<Database>.revert(on: conn))
            try? test(UserMigration<Database>.revert(on: conn))
        }

        try self._benchmark(on: conn)
        self.pool.releaseConnection(conn)
    }
}


