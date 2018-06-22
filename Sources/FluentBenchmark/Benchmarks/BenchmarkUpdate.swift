import Fluent

extension Benchmarker where Database: QuerySupporting {
    fileprivate func _benchmark(on conn: Database.Connection) throws {
        start("Update")
        _ = try test(Planet<Database>(name: "Earth", galaxyID: .init()).create(on: conn))
        _ = try test(Planet<Database>(name: "Mars", galaxyID: .init()).create(on: conn))
        
        let newID = UUID()
        let newName = "Foo"
        
        try test(Planet<Database>.query(on: conn).update(\.name, to: newName).update(\.galaxyID, to: newID).run())
        
        let planets = try test(Planet<Database>.query(on: conn).all())
        if planets.count != 2 {
            fail("wrong planet count: \(planets.count)")
        }
        for planet in planets {
            if planet.name != newName { fail("wrong planet name: \(planet.name)") }
            if planet.galaxyID != newID { fail("wrong galaxy id: \(planet.galaxyID)") }
        }
    }
    
    public func benchmarkUpdate() throws {
        let conn = try test(pool.requestConnection())
        try self._benchmark(on: conn)
        pool.releaseConnection(conn)
    }
}

extension Benchmarker where Database: QuerySupporting & SchemaSupporting & MigrationSupporting {
    public func benchmarkUpdate_withSchema() throws {
        let conn = try test(pool.requestConnection())
        defer { try? test(Galaxy<Database>.revert(on: conn)) }
        try test(Galaxy<Database>.prepare(on: conn))
        defer { try? test(Planet<Database>.revert(on: conn)) }
        try test(Planet<Database>.prepare(on: conn))
        try self._benchmark(on: conn)
        pool.releaseConnection(conn)
    }
}
