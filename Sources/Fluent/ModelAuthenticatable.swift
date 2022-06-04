import FluentKit
import Vapor

public protocol ModelAuthenticatable: Model, Authenticatable {
    static var usernameKey: KeyPath<Self, Field<String>> { get }
    static var passwordHashKey: KeyPath<Self, Field<String>> { get }
    func verify(password: String) throws -> Bool
}

extension ModelAuthenticatable {
    public static func authenticator(
        database: DatabaseID? = nil
    ) -> Authenticator {
        ModelAuthenticator<Self>(database: database)
    }

    var _$username: Field<String> {
        self[keyPath: Self.usernameKey]
    }

    var _$passwordHash: Field<String> {
        self[keyPath: Self.passwordHashKey]
    }
}

@available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
extension ModelAuthenticatable {
    /// Tries to authenticate the user and throws if this fails
    ///
    /// This method tries to find the user with the given username in the database, then checks the password using `verify(password:)`. If this fails, an error is thrown. If it succeeds, the user is logged in to `reqest.auth` and is returned.
    /// - Parameters:
    ///   - username: The username of the user to be authenticated. This uses the field referenced by `usernameKey` from `ModelAuthenticatable`.
    ///   - password: The password to be verified. This uses the field referenced by `passwordHashKey` from `ModelAuthenticatable`.
    ///   - request: The request the authentication is part of
    ///   - database: An optional database ID to be used. If it is not specified, the default request database is used.
    /// - Returns: The authenticated user.
    /// - Throws: `Abort(.unauthorized)` if the authentication fails or any errors from `verify(password:)` or the database query.
    @discardableResult
    public static func authenticate(username: String, password: String, for request: Request, database: DatabaseID? = nil) async throws -> Self {
        let user = try await Self.query(on: request.db(database))
            .filter(\._$username == username)
            .first()
        guard
            let user = user,
            try user.verify(password: password)
        else {
            throw Abort(.unauthorized)
        }
        request.auth.login(user)
        return user
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
