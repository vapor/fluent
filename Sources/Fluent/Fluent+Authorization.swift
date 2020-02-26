import Vapor

extension Authenticatable where Self: Model {
    public static func authorizer<To>(
        parameter: PathComponent,
        isChild childrenKey: KeyPath<Self, Self.Children<To>>,
        databaseID: DatabaseID? = nil
    ) -> ChildrenAuthorizer<Self, To> {
        .init(
            parameter: parameter,
            databaseID: databaseID,
            childrenKey: childrenKey
        )
    }
}

public struct ChildrenAuthorizer<From, To>: ParameterAuthorizer
    where
        From: Model,
        To: Model,
        To.IDValue: LosslessStringConvertible,
        From: Authenticatable,
        To: Authorizable
{
    public var parameter: PathComponent
    public let databaseID: DatabaseID?
    public let childrenKey: KeyPath<From, From.Children<To>>

    public func authorize(parameter: To.IDValue, for request: Request) -> EventLoopFuture<Void> {
        To.find(parameter, on: request.db(self.databaseID))
            .unwrap(or: Abort(.forbidden))
            .flatMapThrowing
        { to in
            let from = try request.authc.require(From.self)
            let fromID: From.IDValue?
            switch From.init()[keyPath: self.childrenKey].parentKey {
            case .required(let key):
                fromID = to[keyPath: key].id
            case .optional(let key):
                fromID = to[keyPath: key].id
            }
            guard fromID == from.id else {
                throw Abort(.forbidden)
            }
            request.authz.add(to)
        }
    }
}
