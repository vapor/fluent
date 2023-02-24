import XCTFluent
import XCTVapor
import Fluent
import Vapor
import FluentKit

final class SessionTests: XCTestCase {
    func testSessionMigrationName() {
        XCTAssertEqual(SessionRecord.migration.name, "Fluent.SessionRecord.Create")
    }
    
    func testSessions() throws {
        let app = Application(.testing)
        defer { app.shutdown() }

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
        try app.test(.GET, "/set/vapor") { res in
            sessionID = res.headers.setCookie?["vapor-session"]?.string
            XCTAssertEqual(res.status, .ok)
        }

        // Add single query output with session data for session read.
        test.append([
            TestOutput([
                "id": UUID(),
                "key": SessionID(string: sessionID!),
                "data": SessionData(initialData: ["name": "vapor"])
            ])
        ])
        // Add empty query output for session update.
        test.append([])
        try app.test(.GET, "/get", beforeRequest: { req in
            var cookies = HTTPCookies()
            cookies["vapor-session"] = .init(string: sessionID!)
            req.headers.cookie = cookies
        }) { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.body.string, "vapor")
        }
    }
}

final class User: Model {
    static let schema = "users"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    init() { }

    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
}

extension User: ModelSessionAuthenticatable { }

extension DatabaseID {
    static var test: Self {
        .init(string: "test")
    }
}

struct StaticDatabase: DatabaseConfiguration, DatabaseDriver {
    let database: Database
    var middleware: [AnyModelMiddleware] = []
    
    func makeDriver(for databases: Databases) -> DatabaseDriver {
        self
    }

    func makeDatabase(with context: DatabaseContext) -> Database {
        self.database
    }

    func shutdown() {
        // Do nothing.
    }
}
