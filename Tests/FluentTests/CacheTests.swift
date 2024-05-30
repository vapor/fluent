import XCTFluent
import XCTVapor
import Fluent
import Vapor

final class CacheTests: XCTestCase {
    var app: Application!
    
    override func setUp() async throws {
        self.app = try await Application.make(.testing)
    }
    
    override func tearDown() async throws {
        try await self.app.asyncShutdown()
        self.app = nil
    }
    
    func testCacheMigrationName() {
        XCTAssertEqual(CacheEntry.migration.name, "Fluent.CacheEntry.Create")
    }
    
    func testCacheGet() async throws {
        // Setup test db.
        let test = ArrayTestDatabase()
        self.app.databases.use(test.configuration, as: .test)
        self.app.migrations.add(CacheEntry.migration)

        // Configure cache.
        self.app.caches.use(.fluent)
        
        // simulate cache miss
        test.append([])
        do {
            let foo = try await self.app.cache.get("foo", as: String.self)
            XCTAssertNil(foo)
        }
        
        // simulate cache hit
        test.append([TestOutput([
            "key": "foo",
            "value": "\"bar\""
        ])])
        do {
            let foo = try await self.app.cache.get("foo", as: String.self)
            XCTAssertEqual(foo, "bar")
        }
    }

    func testCacheSet() async throws {
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
            return [TestOutput(["id": UUID()])]
        }
        self.app.databases.use(test.configuration, as: .test)
        self.app.migrations.add(CacheEntry.migration)

        // Configure cache.
        self.app.caches.use(.fluent)
        
        try await self.app.cache.set("foo", to: "bar")
    }
}
