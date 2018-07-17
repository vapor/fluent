extension Benchmarker where Database: QuerySupporting {
    fileprivate func _benchmark(on conn: Database.Connection) throws {
        start("Range")
        _ = try test(Galaxy<Database>(name: "Milky Way").save(on: conn))
        _ = try test(Galaxy<Database>(name: "Andromeda").save(on: conn))
        _ = try test(Galaxy<Database>(name: "Messier 82").save(on: conn))
        _ = try test(Galaxy<Database>(name: "Tiangulum").save(on: conn))
        _ = try test(Galaxy<Database>(name: "Sunflower").save(on: conn))

        func testCount(_ builder: QueryBuilder<Database, Galaxy<Database>>, _ expected: Int, line: UInt = #line) throws {
            let count = try test(builder.all(), line: line).count
            if count != expected { fail("invalid count: \(count) != \(expected)", line: line) }
        }

        try testCount(Galaxy<Database>.query(on: conn).range(..<1), 1)
        try testCount(Galaxy<Database>.query(on: conn).range(0..<1), 1)
        try testCount(Galaxy<Database>.query(on: conn).range(...1), 2)
        try testCount(Galaxy<Database>.query(on: conn).range(0...1), 2)
        try testCount(Galaxy<Database>.query(on: conn).range(1...1), 1)
        try testCount(Galaxy<Database>.query(on: conn).range(4..<5), 1)
        try testCount(Galaxy<Database>.query(on: conn).range(3..<5), 2)
        try testCount(Galaxy<Database>.query(on: conn).range(2..<4), 2)
    }

    public func benchmarkRange() throws {
        let conn = try test(pool.requestConnection())
        try self._benchmark(on: conn)
        pool.releaseConnection(conn)
    }
}

extension Benchmarker where Database: SchemaSupporting & MigrationSupporting {
    public func benchmarkRange_withSchema() throws {
        let conn = try test(pool.requestConnection())
        defer { try? test(Galaxy<Database>.revert(on: conn)) }
        try test(Galaxy<Database>.prepare(on: conn))
        try self._benchmark(on: conn)
        pool.releaseConnection(conn)
    }
}
