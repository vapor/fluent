import Fluent
import Testing
import Vapor
import VaporTesting
import XCTFluent

@Suite
struct CredentialTests {
    @Test
    func credentialsAuthentication() async throws {
        try await withApp { app in
            let testDB = ArrayTestDatabase()
            app.databases.use(testDB.configuration, as: .test)
            app.middleware.use(app.sessions.middleware)
            let sessionRoutes = app.grouped(CredentialsUser.sessionAuthenticator())
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
            let password = "password-\(Int.random())"
            let passwordHash = try Bcrypt.hash(password)
            let testUser = CredentialsUser(id: UUID(), username: "user-\(Int.random())", password: passwordHash)
            testDB.append([TestOutput(testUser)])
            testDB.append([TestOutput(testUser)])
            testDB.append([TestOutput(testUser)])
            testDB.append([TestOutput(testUser)])

            // Test login
            let loginData = ModelCredentials(username: testUser.username, password: password)
            try await app.test(.POST, "/login", beforeRequest: { req in try req.content.encode(loginData, as: .urlEncodedForm) }) { res in
                #expect(res.status == .seeOther)
                #expect(res.headers[.location].first == "/protected")
                let sessionID = try #require(res.headers.setCookie?["vapor-session"]?.string)

                // Test accessing protected route
                try await app.test(.GET, "/protected", beforeRequest: { req in
                    var cookies = HTTPCookies()
                    cookies["vapor-session"] = .init(string: sessionID)
                    req.headers.cookie = cookies
                }) { res async in
                    #expect(res.status == .ok)
                }
            }
        }
    }

    @Test
    func asyncCredentialsAuthentication() async throws {
        try await withApp { app in
            let testDB = ArrayTestDatabase()
            app.databases.use(testDB.configuration, as: .test)
            app.middleware.use(app.sessions.middleware)
            let sessionRoutes = app.grouped(CredentialsUser.sessionAuthenticator())

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
            let password = "password-\(Int.random())"
            let passwordHash = try Bcrypt.hash(password)
            let testUser = CredentialsUser(id: UUID(), username: "user-\(Int.random())", password: passwordHash)
            testDB.append([TestOutput(testUser)])
            testDB.append([TestOutput(testUser)])
            testDB.append([TestOutput(testUser)])
            testDB.append([TestOutput(testUser)])

            // Test login
            let loginData = ModelCredentials(username: testUser.username, password: password)
            try await app.test(.POST, "/login", beforeRequest: { try $0.content.encode(loginData, as: .urlEncodedForm) }) {
                #expect($0.status == .seeOther)
                #expect($0.headers[.location].first == "/protected")
                let sessionID = try #require($0.headers.setCookie?["vapor-session"]?.string)

                // Test accessing protected route
                try await app.test(.GET, "/protected", beforeRequest: { req in
                    var cookies = HTTPCookies()
                    cookies["vapor-session"] = .init(string: sessionID)
                    req.headers.cookie = cookies
                }) { res async in
                    #expect(res.status == .ok)
                }
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

    init() {}

    init(id: UUID? = nil, username: String, password: String) {
        self.id = id
        self.username = username
        self.password = password
    }
}

extension CredentialsUser: ModelCredentialsAuthenticatable {
    static var usernameKey: KeyPath<CredentialsUser, Field<String>> { \.$username }
    static var passwordHashKey: KeyPath<CredentialsUser, Field<String>> { \.$password }

    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.password)
    }
}
extension CredentialsUser: ModelSessionAuthenticatable {}
