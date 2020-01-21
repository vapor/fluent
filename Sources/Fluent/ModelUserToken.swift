import Vapor

public protocol ModelUserToken: Model {
    associatedtype User: Model & Authenticatable
    static var valueKey: KeyPath<Self, Field<String>> { get }
    static var userKey: KeyPath<Self, Parent<User>> { get }
    var isValid: Bool { get }
}

extension ModelUserToken {
    public static func authenticator(
        database: DatabaseID? = nil
    ) -> ModelUserTokenAuthenticator<Self> {
        ModelUserTokenAuthenticator<Self>(database: database)
    }

    var _$value: Field<String> {
        self[keyPath: Self.valueKey]
    }

    var _$user: Parent<User> {
        self[keyPath: Self.userKey]
    }
}

public struct ModelUserTokenAuthenticator<Token>: BearerAuthenticator
    where Token: ModelUserToken
{
    public typealias User = Token.User
    public let database: DatabaseID?

    public func authenticate(
        bearer: BearerAuthorization,
        for request: Request
    ) -> EventLoopFuture<User?> {
        let db = request.db(self.database)
        return Token.query(on: db)
            .filter(\._$value == bearer.token)
            .first()
            .flatMap
        { token -> EventLoopFuture<User?> in
            guard let token = token else {
                return request.eventLoop.makeSucceededFuture(nil)
            }
            guard token.isValid else {
                return token.delete(on: db).map { nil }
            }
            return token._$user.get(on: db)
                .map { $0 }
        }
    }
}

