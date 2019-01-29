import Fluent

extension Benchmarker where Database: QuerySupporting {
    fileprivate func _benchmark(on conn: Database.Connection) throws {
        start("Aggregate")
        _ = try test(Galaxy<Database>(name: "Andromeda").create(on: conn))
        _ = try test(Galaxy<Database>(name: "Milky Way").create(on: conn))
        
        let builder = Galaxy<Database>.query(on: conn).filter(\.name == "Milky Way")
        // test the ability to use all() _after_ count()
        // this can fail if the query builder is not properly removing aggregates
        let count = try test(builder.count())
        let all = try test(builder.all())
        if all.count != count {
            fail("wrong count: \(all.count) != \(count)")
        }
        
        let firstSummer = User<Database>(name: "Summer", age: 30)
        let secondSummer = User<Database>(name: "Summer", age: 31)
        _ = try test(firstSummer.create(on: conn))
        _ = try test(secondSummer.create(on: conn))
        let summersSum = try User<Database>.query(on: conn).filter(\.name == "Summer").sum(\.age).wait()
        if summersSum != 61 {
            fail("sum should be 61")
        }
        
        let autumn = User<Database>(name: "Autumn", age: 40)
        do {
            _ = try User<Database>.query(on: conn).filter(\.name == "Autumn").sum(\.age).wait()
            fail("should not have produced a sum")
        } catch {
            let defaultSum = try User<Database>.query(on: conn).filter(\.name == "Autumn").sum(\.age, default: 0).wait()
            if defaultSum != 0 {
                fail("should have defaulted to 0")
            }
        }
        
        _ = try test(autumn.create(on: conn))
        let autumnsSum = try User<Database>.query(on: conn).filter(\.name == "Autumn").sum(\.age).wait()
        let alsoAutumnsSum = try User<Database>.query(on: conn).filter(\.name == "Autumn").sum(\.age, default: 0).wait()
        if autumnsSum != 40 || alsoAutumnsSum != 40 {
            fail("sum should be 40, whether or not a default is provided")
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
        defer {
            try? test(Galaxy<Database>.revert(on: conn))
            try? test(UserMigration<Database>.revert(on: conn))
        }
        try test(Galaxy<Database>.prepare(on: conn))
        try test(UserMigration<Database>.prepare(on: conn))
        try self._benchmark(on: conn)
        pool.releaseConnection(conn)
    }
}
