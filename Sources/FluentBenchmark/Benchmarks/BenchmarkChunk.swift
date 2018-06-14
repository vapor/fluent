import Fluent

extension Benchmarker where Database: QuerySupporting {
    /// The actual benchmark.
    fileprivate func _benchmark(on conn: Database.Connection) throws {
        var fetched64: [User<Database>] = []
        var fetched2047: [User<Database>] = []

        
        for i in 1...512 {
            let user = User<Database>(name: "User \(i)", age: i)
            _ = try test(user.save(on: conn))
        }

        try test(User<Database>.query(on: conn).chunk(max: 64) { chunk in
            if chunk.count == 0 {
                print("[warning] zero length chunk. there is probably an extraneous close happening")
                return
            }
            if chunk.count != 64 {
                self.fail("bad chunk count")
            }
            fetched64 += chunk
        })


        if fetched64.count != 512 {
            self.fail("did not fetch all - only \(fetched64.count) out of 512")
        }

        _ = try test(User<Database>.query(on: conn).chunk(max: 511) { chunk in
            if chunk.count == 0 {
                print("[warning] zero length chunk. there is probably an extraneous close happening")
                return
            }
            
            if chunk.count != 511 && chunk.count != 1 {
                self.fail("bad chunk count")
            }
            fetched2047 += chunk
        })

        if fetched2047.count != 512 {
            self.fail("did not fetch all - only \(fetched2047.count) out of 512")
        }
    }

    /// Benchmark result chunking
    public func benchmarkChunking() throws {
        let conn = try test(pool.requestConnection())
        do {
            try self._benchmark(on: conn)
        } catch {
            fail("\(error)")
        }
        pool.releaseConnection(conn)
    }
}

extension Benchmarker where Database: SchemaSupporting & MigrationSupporting & QuerySupporting {
    /// Benchmark result chunking
    /// The schema will be prepared first.
    public func benchmarkChunking_withSchema() throws {
        let conn = try test(pool.requestConnection())
        try test(UserMigration<Database>.prepare(on: conn))
        defer {
            try? test(UserMigration<Database>.revert(on: conn))
        }
        try self._benchmark(on: conn)
        pool.releaseConnection(conn)
    }
}
