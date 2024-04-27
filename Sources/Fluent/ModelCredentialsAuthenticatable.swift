import Vapor
import NIOCore
import FluentKit

public protocol ModelCredentialsAuthenticatable: Model, Authenticatable {
    static var usernameKey: KeyPath<Self, Field<String>> { get }
    static var passwordHashKey: KeyPath<Self, Field<String>> { get }
    func verify(password: String) throws -> Bool
}

extension ModelCredentialsAuthenticatable {
    public static func credentialsAuthenticator(
        database: DatabaseID? = nil
    ) -> any Authenticator {
        ModelCredentialsAuthenticator<Self>(database: database)
    }

    var _$username: Field<String> {
        self[keyPath: Self.usernameKey]
    }

    var _$passwordHash: Field<String> {
        self[keyPath: Self.passwordHashKey]
    }
}

public struct ModelCredentials: Content, Sendable {
    public let username: String
    public let password: String

    public init(username: String, password: String) {
        self.username = username
        self.password = password
    }
}

private struct ModelCredentialsAuthenticator<User>: CredentialsAuthenticator
    where User: ModelCredentialsAuthenticatable
{
    typealias Credentials = ModelCredentials

    public let database: DatabaseID?

    func authenticate(credentials: ModelCredentials, for request: Request) -> EventLoopFuture<Void> {
        User.query(on: request.db(self.database)).filter(\._$username == credentials.username).first().flatMapThrowing { foundUser in
            guard let user = foundUser else {
                return
            }
            guard try user.verify(password: credentials.password) else {
                return
            }
            request.auth.login(user)
        }
    }
}

