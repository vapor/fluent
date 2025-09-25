import Fluent
import Testing
import Vapor
import VaporTesting
import XCTFluent

@Suite
struct SessionTests {
    @Test
    func sessionMigrationName() {
        #expect(SessionRecord.migration.name == "Fluent.SessionRecord.Create")
    }

    @Test
    func sessions() async throws {
        try await withApp { app in
            // Setup test db.
            let test = ArrayTestDatabase()
            app.databases.use(test.configuration, as: .test)
            app.migrations.add(SessionRecord.migration)

            // Configure sessions.
            app.sessions.use(.fluent)
            app.middleware.use(app.sessions.middleware)

            // Setup routes.
            app.get("set", ":value") { req -> HTTPStatus in
                req.session.data["name"] = req.parameters.get("value")
                return .ok
            }
            app.get("get") { req -> String in
                req.session.data["name"] ?? "n/a"
            }
            app.get("del") { req -> HTTPStatus in
                req.session.destroy()
                return .ok
            }

            // Add single query output with empty row.
            test.append([TestOutput()])
            // Store session id.
            var sessionID: String?
            try await app.test(.GET, "/set/vapor") { res async in
                sessionID = res.headers.setCookie?["vapor-session"]?.string
                #expect(res.status == .ok)
            }

            // Add single query output with session data for session read.
            test.append([TestOutput([
                "id": UUID(),
                "key": SessionID(string: sessionID!),
                "data": SessionData(initialData: ["name": "vapor"]),
            ])])
            // Add empty query output for session update.
            test.append([])
            try await app.test(.GET, "/get", beforeRequest: { req async in
                var cookies = HTTPCookies()
                cookies["vapor-session"] = .init(string: sessionID!)
                req.headers.cookie = cookies
            }) { res async in
                #expect(res.status == .ok)
                #expect(res.body.string == "vapor")
            }
        }
    }
}

final class User: Model, @unchecked Sendable {
    static let schema = "users"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    init() {}

    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
}

extension User: ModelSessionAuthenticatable {}

extension DatabaseID {
    static var test: Self {
        .init(string: "test")
    }
}

struct StaticDatabase: DatabaseConfiguration, DatabaseDriver {
    let database: any Database
    var middleware: [any AnyModelMiddleware] = []

    func makeDriver(for databases: Databases) -> any DatabaseDriver {
        self
    }

    func makeDatabase(with context: DatabaseContext) -> any Database {
        self.database
    }

    func shutdown() {
        // Do nothing.
    }

    func shutdownAsync() async {
        // Do nothing
    }
}
