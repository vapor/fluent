import NIOCore
import Vapor
import FluentKit

extension Model where Self: SessionAuthenticatable, Self.SessionID == Self.IDValue {
    public static func asyncSessionAuthenticator(
        _ databaseID: DatabaseID? = nil
    ) -> any AsyncAuthenticator {
        AsyncDatabaseSessionAuthenticator<Self>(databaseID: databaseID)
    }
}

private struct AsyncDatabaseSessionAuthenticator<User>: AsyncSessionAuthenticator
    where User: SessionAuthenticatable, User: Model, User.SessionID == User.IDValue
{
    let databaseID: DatabaseID?

    func authenticate(sessionID: User.SessionID, for request: Request) async throws {
        if let user = try await User.find(sessionID, on: request.db(self.databaseID)) {
            request.auth.login(user)
        }
    }
}
