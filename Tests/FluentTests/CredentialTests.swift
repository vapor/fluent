import XCTFluent
import XCTVapor
import Fluent
import Vapor
import FluentKit

final class CredentialTests: XCTestCase {
    var app: Application!
    
    override func setUp() async throws {
        self.app = try await Application.make(.testing)
    }
    
    override func tearDown() async throws {
        try await self.app.asyncShutdown()
        self.app = nil
    }
    
    func testCredentialsAuthentication() async throws {
        let testDB = ArrayTestDatabase()
        self.app.databases.use(testDB.configuration, as: .test)
        self.app.middleware.use(self.app.sessions.middleware)
        let sessionRoutes = self.app.grouped(CredentialsUser.sessionAuthenticator())
        sessionRoutes.grouped(CredentialsUser.credentialsAuthenticator()).post("login") { req in
            guard req.auth.has(CredentialsUser.self) else {
                throw Abort(.unauthorized)
            }
            return req.redirect(to: "/protected")
        }
        sessionRoutes.grouped(CredentialsUser.redirectMiddleware(path: "/login")).get("protected") { req in
            _ = try req.auth.require(CredentialsUser.self)
            return HTTPStatus.ok
        }

        // Create user
        let password = "password-\(Int.random())", passwordHash = try Bcrypt.hash(password)
        let testUser = CredentialsUser(id: UUID(), username: "user-\(Int.random())", password: passwordHash)
        testDB.append([TestOutput(testUser)])
        testDB.append([TestOutput(testUser)])
        testDB.append([TestOutput(testUser)])
        testDB.append([TestOutput(testUser)])

        // Test login
        let loginData = ModelCredentials(username: testUser.username, password: password)
        try await self.app.test(.POST, "/login", beforeRequest: { req in
            try req.content.encode(loginData, as: .urlEncodedForm)
        }) { res in
            XCTAssertEqual(res.status, .seeOther)
            XCTAssertEqual(res.headers[.location].first, "/protected")
            let sessionID = try XCTUnwrap(res.headers.setCookie?["vapor-session"]?.string)

            // Test accessing protected route
            try await self.app.test(.GET, "/protected", beforeRequest: { req in
                var cookies = HTTPCookies()
                cookies["vapor-session"] = .init(string: sessionID)
                req.headers.cookie = cookies
            }) { res async in
                XCTAssertEqual(res.status, .ok)
            }
        }
    }
    
    func testAsyncCredentialsAuthentication() async throws {
        let testDB = ArrayTestDatabase()
        self.app.databases.use(testDB.configuration, as: .test)
        self.app.middleware.use(self.app.sessions.middleware)
        let sessionRoutes = self.app.grouped(CredentialsUser.sessionAuthenticator())

        sessionRoutes.grouped(CredentialsUser.asyncCredentialsAuthenticator()).post("login") { req async throws in
            guard req.auth.has(CredentialsUser.self) else {
                throw Abort(.unauthorized)
            }
            return req.redirect(to: "/protected")
        }
        sessionRoutes.grouped(CredentialsUser.redirectMiddleware(path: "/login")).get("protected") { req async throws in
            _ = try req.auth.require(CredentialsUser.self)
            return HTTPStatus.ok
        }

        // Create user
        let password = "password-\(Int.random())", passwordHash = try Bcrypt.hash(password)
        let testUser = CredentialsUser(id: UUID(), username: "user-\(Int.random())", password: passwordHash)
        testDB.append([TestOutput(testUser)])
        testDB.append([TestOutput(testUser)])
        testDB.append([TestOutput(testUser)])
        testDB.append([TestOutput(testUser)])

        // Test login
        let loginData = ModelCredentials(username: testUser.username, password: password)
        try await self.app.test(.POST, "/login", beforeRequest: { try $0.content.encode(loginData, as: .urlEncodedForm) }) {
            XCTAssertEqual($0.status, .seeOther)
            XCTAssertEqual($0.headers[.location].first, "/protected")
            let sessionID = try XCTUnwrap($0.headers.setCookie?["vapor-session"]?.string)

            // Test accessing protected route
            try await app.test(.GET, "/protected", beforeRequest: { req in
                var cookies = HTTPCookies()
                cookies["vapor-session"] = .init(string: sessionID)
                req.headers.cookie = cookies
            }) { res async in
                XCTAssertEqual(res.status, .ok)
            }
        }
    }
}

final class CredentialsUser: Model, @unchecked Sendable {
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
