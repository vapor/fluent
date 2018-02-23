import Async
import Dispatch
import Fluent
import Foundation

extension Benchmarker where Database: QuerySupporting & TransactionSupporting {
    /// The actual benchmark.
    fileprivate func _benchmark(on conn: Database.Connection) throws {
        let cache = FluentCache<Database>(pool: pool)

        // get empty
        let first = try test(cache.get(FooCache.self, forKey: "hello"))
        if first != nil {
            fail("cache was not empty")
        }

        // save
        let example = FooCache(bar: "swift rulez", baz: 42)
        try test(cache.set(example, forKey: "hello"))

        // fetch saved
        let fetched = try test(cache.get(FooCache.self, forKey: "hello"))
        if let foo = fetched {
            if foo.bar != "swift rulez" { fail("invalid bar") }
            if foo.baz != 42 { fail("invalid baz") }
        } else {
            fail("fetched was nil")
        }

        // delete
        try test(cache.remove("hello"))

        let failed = try test(cache.get(FooCache.self, forKey: "hello"))
        if failed != nil {
            fail("delete failed")
        }
    }

    /// Benchmark fluent transactions.
    public func benchmarkCache() throws {
        let conn = try test(pool.requestConnection())
        try self._benchmark(on: conn)
        pool.releaseConnection(conn)
    }
}

struct FooCache: Codable {
    var bar: String
    var baz: Int
}

extension Benchmarker where Database: QuerySupporting & TransactionSupporting & SchemaSupporting {
    /// Benchmark fluent transactions.
    /// The schema will be prepared first.
    public func benchmarkCache_withSchema() throws {
        let conn = try test(pool.requestConnection())
        try test(FluentCacheEntry<Database>.prepare(on: conn))
        defer {
            try? test(FluentCacheEntry<Database>.revert(on: conn))
        }
        try self._benchmark(on: conn)
        pool.releaseConnection(conn)
    }
}
