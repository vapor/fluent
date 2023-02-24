import XCTFluent
import XCTVapor
import Fluent
import Vapor
import FluentKit

final class CredentialTests: XCTestCase {

    func testCredentialsAuthentication() throws {
        let app = Application(.testing)
        defer { app.shutdown() }

        // Setup test db.
        let testDB = ArrayTestDatabase()
        app.databases.use(testDB.configuration, as: .test)

        // Configure sessions.
        app.middleware.use(app.sessions.middleware)

        // Setup routes.
        let sessionRoutes = app.grouped(CredentialsUser.sessionAuthenticator())

        let credentialRoutes = sessionRoutes.grouped(CredentialsUser.credentialsAuthenticator())
        credentialRoutes.post("login") { req -> Response in
            guard req.auth.has(CredentialsUser.self) else {
                throw Abort(.unauthorized)
            }
            return req.redirect(to: "/protected")
        }

        let protectedRoutes = sessionRoutes.grouped(CredentialsUser.redirectMiddleware(path: "/login"))
        protectedRoutes.get("protected") { req -> HTTPStatus in
            _ = try req.auth.require(CredentialsUser.self)
            return .ok
        }

        // Create user
        let password = "password-\(Int.random())"
        let passwordHash = try Bcrypt.hash(password)
        let testUser = CredentialsUser(id: UUID(), username: "user-\(Int.random())", password: passwordHash)
        testDB.append([TestOutput(testUser)])
        testDB.append([TestOutput(testUser)])
        testDB.append([TestOutput(testUser)])
        testDB.append([TestOutput(testUser)])

        // Test login
        let loginData = ModelCredentials(username: testUser.username, password: password)
        try app.test(.POST, "/login", beforeRequest: { req in
            try req.content.encode(loginData, as: .urlEncodedForm)
        }) { res in
            XCTAssertEqual(res.status, .seeOther)
            XCTAssertEqual(res.headers[.location].first, "/protected")
            let sessionID = try XCTUnwrap(res.headers.setCookie?["vapor-session"]?.string)

            // Test accessing protected route
            try app.test(.GET, "/protected", beforeRequest: { req in
                var cookies = HTTPCookies()
                cookies["vapor-session"] = .init(string: sessionID)
                req.headers.cookie = cookies
            }) { res in
                XCTAssertEqual(res.status, .ok)
            }
        }
    }
    
#if compiler(>=5.5) && canImport(_Concurrency)
    @available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
    func testAsyncCredentialsAuthentication() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }

        
        // Setup test db.
        let testDB = ArrayTestDatabase()
        
        app.databases.use(testDB.configuration, as: .test)

        // Configure sessions.
        app.middleware.use(app.sessions.middleware)

        // Setup routes.
        let sessionRoutes = app.grouped(CredentialsUser.sessionAuthenticator())

        let credentialRoutes = sessionRoutes.grouped(CredentialsUser.asyncCredentialsAuthenticator())
        credentialRoutes.post("login") { req -> Response in
            guard req.auth.has(CredentialsUser.self) else {
                throw Abort(.unauthorized)
            }
            return req.redirect(to: "/protected")
        }

        let protectedRoutes = sessionRoutes.grouped(CredentialsUser.redirectMiddleware(path: "/login"))
        protectedRoutes.get("protected") { req -> HTTPStatus in
            _ = try req.auth.require(CredentialsUser.self)
            return .ok
        }

        // Create user
        let password = "password-\(Int.random())"
        let passwordHash = try Bcrypt.hash(password)
        let testUser = CredentialsUser(id: UUID(), username: "user-\(Int.random())", password: passwordHash)
        testDB.append([TestOutput(testUser)])
        testDB.append([TestOutput(testUser)])
        testDB.append([TestOutput(testUser)])
        testDB.append([TestOutput(testUser)])

        // Test login
        let loginData = ModelCredentials(username: testUser.username, password: password)
        try app.test(.POST, "/login", beforeRequest: { req in
            try req.content.encode(loginData, as: .urlEncodedForm)
        }) { res in
            XCTAssertEqual(res.status, .seeOther)
            XCTAssertEqual(res.headers[.location].first, "/protected")
            let sessionID = try XCTUnwrap(res.headers.setCookie?["vapor-session"]?.string)

            // Test accessing protected route
            try app.test(.GET, "/protected", beforeRequest: { req in
                var cookies = HTTPCookies()
                cookies["vapor-session"] = .init(string: sessionID)
                req.headers.cookie = cookies
            }) { res in
                XCTAssertEqual(res.status, .ok)
            }
        }
    }
#endif
}

final class CredentialsUser: Model {
    static let schema = "users"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "username")
    var username: String

    @Field(key: "password")
    var password: String

    init() { }

    init(id: UUID? = nil, username: String, password: String) {
        self.id = id
        self.username = username
        self.password = password
    }
}


extension CredentialsUser: ModelCredentialsAuthenticatable {
    static let usernameKey = \CredentialsUser.$username
    static let passwordHashKey = \CredentialsUser.$password

    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.password)
    }
}
extension CredentialsUser: ModelSessionAuthenticatable {}
