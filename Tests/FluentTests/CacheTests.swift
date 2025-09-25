import Fluent
import Testing
import Vapor
import VaporTesting
import XCTFluent

@Suite
struct CacheTests {
    @Test
    func cacheMigrationName() {
        #expect(CacheEntry.migration.name == "Fluent.CacheEntry.Create")
    }

    @Test
    func cacheGet() async throws {
        try await withApp { app in
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
                #expect(foo == nil)
            }

            // simulate cache hit
            test.append([TestOutput(["key": "foo", "value": #""bar""#])])
            do {
                let foo = try await app.cache.get("foo", as: String.self)
                #expect(foo == "bar")
            }
        }
    }

    @Test
    func cacheSet() async throws {
        try await withApp { app in
            // Setup test db.
            let test = CallbackTestDatabase { query in
                switch query.input[0] {
                case .dictionary(let dict):
                    switch dict["value"] {
                    case .bind(let value as String):
                        #expect(value == #""bar""#)
                    default:
                        Issue.record("unexpected value")
                    }
                default:
                    Issue.record("unexpected input")
                }
                return [TestOutput(["id": UUID()])]
            }
            app.databases.use(test.configuration, as: .test)
            app.migrations.add(CacheEntry.migration)

            // Configure cache.
            app.caches.use(.fluent)

            try await app.cache.set("foo", to: "bar")
        }
    }
}
