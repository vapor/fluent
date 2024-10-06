import XCTFluent
import XCTVapor
import Fluent
import Vapor
import FluentKit

final class SessionTests: XCTestCase {
    var app: Application!
    
    override func setUp() async throws {
        self.app = try await Application.make(.testing)
    }
    
    override func tearDown() async throws {
        try await self.app.asyncShutdown()
        self.app = nil
    }
    
    func testSessionMigrationName() {
        XCTAssertEqual(SessionRecord.migration.name, "Fluent.SessionRecord.Create")
    }
    
    func testSessions() async throws {
        // Setup test db.
        let test = ArrayTestDatabase()
        self.app.databases.use(test.configuration, as: .test)
        self.app.migrations.add(SessionRecord.migration)

        // Configure sessions.
        self.app.sessions.use(.fluent)
        self.app.middleware.use(self.app.sessions.middleware)

        // Setup routes.
        self.app.get("set", ":value") { req -> HTTPStatus in
            req.session.data["name"] = req.parameters.get("value")
            return .ok
        }
        self.app.get("get") { req -> String in
            req.session.data["name"] ?? "n/a"
        }
        self.app.get("del") { req -> HTTPStatus in
            req.session.destroy()
            return .ok
        }

        // Add single query output with empty row.
        test.append([TestOutput()])
        // Store session id.
        var sessionID: String?
        try await self.app.test(.GET, "/set/vapor") { res async in
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
        try await self.app.test(.GET, "/get", beforeRequest: { req async in
            var cookies = HTTPCookies()
            cookies["vapor-session"] = .init(string: sessionID!)
            req.headers.cookie = cookies
        }) { res async in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.body.string, "vapor")
        }
    }
}

final class User: Model, @unchecked Sendable {
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
