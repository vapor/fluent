import Vapor
import FluentKit

public protocol ModelTokenAuthenticatable: Model, Authenticatable {
    associatedtype User: Model & Authenticatable
    static var valueKey: KeyPath<Self, Field<String>> { get }
    static var userKey: KeyPath<Self, Parent<User>> { get }
    var isValid: Bool { get }
}

extension ModelTokenAuthenticatable {
    public static func authenticator(
        database: DatabaseID? = nil
    ) -> Authenticator {
        ModelTokenAuthenticator<Self>(database: database)
    }

    var _$value: Field<String> {
        self[keyPath: Self.valueKey]
    }

    var _$user: Parent<User> {
        self[keyPath: Self.userKey]
    }
}

private struct ModelTokenAuthenticator<Token>: BearerAuthenticator
    where Token: ModelTokenAuthenticatable
{
    public typealias User = Token.User
    public let database: DatabaseID?

    public func authenticate(
        bearer: BearerAuthorization,
        for request: Request
    ) -> EventLoopFuture<Void> {
        let db = request.db(self.database)
        return Token.query(on: db)
            .filter(\._$value == bearer.token)
            .first()
            .flatMap
        { token -> EventLoopFuture<Void> in
            guard let token = token else {
                return request.eventLoop.makeSucceededFuture(())
            }
            guard token.isValid else {
                return token.delete(on: db)
            }
            request.auth.login(token)
            return token._$user.get(on: db).map {
                request.auth.login($0)
            }
        }
    }
}

