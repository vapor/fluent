import XCTFluent
import XCTVapor
import Fluent
import Vapor

final class CacheTests: XCTestCase {
    func testCacheMigrationName() {
        XCTAssertEqual(CacheEntry.migration.name, "Fluent.CacheEntry.Create")
    }
    
    func testCacheGet() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }

        // Setup test db.
        let test = ArrayTestDatabase()
        app.databases.use(test.configuration, as: .test)
        app.migrations.add(CacheEntry.migration)

        // Configure cache.
        app.caches.use(.fluent)
        
        // simulate cache miss
        test.append([])
        do {
            let foo = try await app.cache.get("foo", as: String.self)
            XCTAssertNil(foo)
        }
        
        // simulate cache hit
        test.append([TestOutput([
            "key": "foo",
            "value": "\"bar\""
        ])])
        do {
            let foo = try await app.cache.get("foo", as: String.self)
            XCTAssertEqual(foo, "bar")
        }
    }

    func testCacheSet() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }

        // Setup test db.
        let test = CallbackTestDatabase { query in
            switch query.input[0] {
            case .dictionary(let dict):
                switch dict["value"] {
                case .bind(let value as String):
                    XCTAssertEqual(value, "\"bar\"")
                default: XCTFail("unexpected value")
                }
                
            default: XCTFail("unexpected input")
            }
            return [
                TestOutput(["id": UUID()])
            ]
        }
        app.databases.use(test.configuration, as: .test)
        app.migrations.add(CacheEntry.migration)

        // Configure cache.
        app.caches.use(.fluent)
        
        try await app.cache.set("foo", to: "bar")
    }
}
