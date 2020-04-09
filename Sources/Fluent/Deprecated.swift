import Vapor

@available(*, deprecated, renamed: "ModelAuthenticatable")
public typealias ModelUser = ModelAuthenticatable

@available(*, deprecated, renamed: "ModelAuthenticatable")
public typealias ModelUserToken = ModelTokenAuthenticatable

extension Application.Fluent.Sessions {
    @available(*, deprecated, renamed: "Model.sessionAuthenticator()")
    public func middleware<User>(
        for user: User.Type,
        databaseID: DatabaseID? = nil
    ) -> Middleware
        where User: SessionAuthenticatable, User: Model, User.SessionID == User.IDValue
    {
        User.sessionAuthenticator(databaseID)
    }
}
