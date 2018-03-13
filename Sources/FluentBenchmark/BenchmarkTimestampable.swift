import Async
import Dispatch
import Fluent
import Foundation

extension Benchmarker where Database: QuerySupporting {
    /// The actual benchmark.
    fileprivate func _benchmark(on conn: Database.Connection) throws {
        // create
        let tanner = User<Database>(name: "Tanner", age: 23)
        if tanner.createdAt != nil || tanner.updatedAt != nil {
            self.fail("timestamps should have been nil")
        }

        _ = try test(tanner.save(on: conn))
        if tanner.createdAt?.isWithin(seconds: 0.1, of: Date()) != true {
            self.fail("timestamps should be current")
        }

        if tanner.updatedAt?.isWithin(seconds: 0.1, of: Date()) != true {
            self.fail("timestamps should be current")
        }

        let originalUpdatedAt = tanner.updatedAt!
        // Ensure that there is a substantial difference between `originalUpdatedAt` and `updatedAt`.
        Thread.sleep(forTimeInterval: 0.05)
        _ = try test(tanner.save(on: conn))

        if tanner.updatedAt! <= originalUpdatedAt {
            self.fail("new updated at should be greater")
        }
        
        let f = try test(conn.query(User<Database>.self).filter(\.name == "Tanner").first())
        guard let fetched = f else {
            self.fail("could not fetch user")
            return
        }

        if !fetched.createdAt!.isWithin(seconds: 0.002, of: tanner.createdAt!) {
            self.fail("fetched createdAt timestamp \(fetched.createdAt!.timeIntervalSince1970) is more than 2ms different from expected value \(tanner.createdAt!.timeIntervalSince1970)")
        }
        if !fetched.updatedAt!.isWithin(seconds: 0.002, of: tanner.updatedAt!) {
            self.fail("fetched updatedAt timestamp \(fetched.updatedAt!.timeIntervalSince1970) is more than 2ms different from expected value \(tanner.updatedAt!.timeIntervalSince1970)")
        }
    }

    /// Benchmark the Timestampable protocol
    public func benchmarkTimestampable() throws {
        let conn = try test(pool.requestConnection())
        try self._benchmark(on: conn)
        pool.releaseConnection(conn)
    }
}

extension Benchmarker where Database: QuerySupporting & SchemaSupporting {
    /// Benchmark the Timestampable protocol
    /// The schema will be prepared first.
    public func benchmarkTimestampable_withSchema() throws {
        let conn = try test(pool.requestConnection())
        try test(UserMigration<Database>.prepare(on: conn))
        defer {
            try? test(UserMigration<Database>.revert(on: conn))
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
