import Vapor

public protocol ModelUser: Model, Authenticatable {
    static var usernameKey: KeyPath<Self, Field<String>> { get }
    static var passwordHashKey: KeyPath<Self, Field<String>> { get }
    func verify(password: String) throws -> Bool
}

extension ModelUser {
    public static func authenticator(
        database: DatabaseID? = nil
    ) -> ModelUserAuthenticator<Self> {
        ModelUserAuthenticator<Self>(database: database)
    }

    var _$username: Field<String> {
        self[keyPath: Self.usernameKey]
    }

    var _$passwordHash: Field<String> {
        self[keyPath: Self.passwordHashKey]
    }
}

public struct ModelUserAuthenticator<User>: BasicAuthenticator
    where User: ModelUser
{
    public let database: DatabaseID?

    public func authenticate(
        basic: BasicAuthorization,
        for request: Request
    ) -> EventLoopFuture<User?> {
        User.query(on: request.db(self.database))
            .filter(\._$username == basic.username)
            .first()
            .flatMapThrowing
        {
            guard let user = $0 else {
                return nil
            }
            guard try user.verify(password: basic.password) else {
                return nil
            }
            return user
        }
    }
}
