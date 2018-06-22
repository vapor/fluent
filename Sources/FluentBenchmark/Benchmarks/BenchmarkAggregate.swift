import Fluent

extension Benchmarker where Database: QuerySupporting {
    fileprivate func _benchmark(on conn: Database.Connection) throws {
        _ = try test(Galaxy<Database>(name: "Andromeda").create(on: conn))
        _ = try test(Planet<Database>(name: "Milky Way", galaxyID: .init()).create(on: conn))
        
        let builder = Planet<Database>.query(on: conn).filter(\.name == "Milky Way")
        // test the ability to use all() _after_ count()
        // this can fail if the query builder is not properly removing aggregates
        let count = try test(builder.count())
        let all = try test(builder.all())
        if all.count != count {
            fail("wrong count: \(all.count) != \(count)")
        }
    }
    
    public func benchmarkAggregate() throws {
        let conn = try test(pool.requestConnection())
        try self._benchmark(on: conn)
        pool.releaseConnection(conn)
    }
}

extension Benchmarker where Database: QuerySupporting & SchemaSupporting & MigrationSupporting {
    public func benchmarkAggregate_withSchema() throws {
        let conn = try test(pool.requestConnection())
        defer { try? test(Galaxy<Database>.revert(on: conn)) }
        try test(Galaxy<Database>.prepare(on: conn))
        try self._benchmark(on: conn)
        pool.releaseConnection(conn)
    }
}
