extension Benchmarker where Database: QuerySupporting {
    fileprivate func _benchmark(on conn: Database.Connection) throws {
        start("Subset")
        let milkyWay = try test(Galaxy<Database>(name: "Milky Way").save(on: conn))
        let andromeda = try test(Galaxy<Database>(name: "Andromeda").save(on: conn))
        let messier82 = try test(Galaxy<Database>(name: "Messier 82").save(on: conn))
        _ = try test(Galaxy<Database>(name: "Tiangulum").save(on: conn))
        _ = try test(Galaxy<Database>(name: "Sunflower").save(on: conn))
        
        func testCount(_ builder: QueryBuilder<Database, Galaxy<Database>>, _ expected: Int, line: UInt = #line) throws {
            let count = try test(builder.all(), line: line).count
            if count != expected { fail("invalid count: \(count) != \(expected)", line: line) }
        }

        try testCount(Galaxy<Database>.query(on: conn).filter(\.id ~~ []), 0)
        try testCount(Galaxy<Database>.query(on: conn).filter(\.id ~~ [milkyWay.requireID()]), 1)
        try testCount(Galaxy<Database>.query(on: conn).filter(\.id ~~ [milkyWay.requireID(), andromeda.requireID()]), 2)
        try testCount(Galaxy<Database>.query(on: conn).filter(\.id ~~ [milkyWay.requireID(), andromeda.requireID(), messier82.requireID()]), 3)
    }
    
    public func benchmarkSubset() throws {
        let conn = try test(pool.requestConnection())
        try self._benchmark(on: conn)
        pool.releaseConnection(conn)
    }
}

extension Benchmarker where Database: SchemaSupporting & MigrationSupporting {
    public func benchmarkSubset_withSchema() throws {
        let conn = try test(pool.requestConnection())
        defer { try? test(Galaxy<Database>.revert(on: conn)) }
        try test(Galaxy<Database>.prepare(on: conn))
        try self._benchmark(on: conn)
        pool.releaseConnection(conn)
    }
}
