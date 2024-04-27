import Vapor
import NIOCore
import FluentKit

public protocol ModelAuthenticatable: Model, Authenticatable {
    static var usernameKey: KeyPath<Self, Field<String>> { get }
    static var passwordHashKey: KeyPath<Self, Field<String>> { get }
    func verify(password: String) throws -> Bool
}

extension ModelAuthenticatable {
    public static func authenticator(
        database: DatabaseID? = nil
    ) -> any Authenticator {
        ModelAuthenticator<Self>(database: database)
    }

    var _$username: Field<String> {
        self[keyPath: Self.usernameKey]
    }

    var _$passwordHash: Field<String> {
        self[keyPath: Self.passwordHashKey]
    }
}

private struct ModelAuthenticator<User>: BasicAuthenticator
    where User: ModelAuthenticatable
{
    public let database: DatabaseID?

    public func authenticate(
        basic: BasicAuthorization,
        for request: Request
    ) -> EventLoopFuture<Void> {
        User.query(on: request.db(self.database))
            .filter(\._$username == basic.username)
            .first()
            .flatMapThrowing
        {
            guard let user = $0 else {
                return
            }
            guard try user.verify(password: basic.password) else {
                return
            }
            request.auth.login(user)
        }
    }
}
