#if compiler(>=5.5) && canImport(_Concurrency)
import NIOCore
import Vapor
import FluentKit

@available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
extension Model where Self: SessionAuthenticatable, Self.SessionID == Self.IDValue {
    public static func asyncSessionAuthenticator(
        _ databaseID: DatabaseID? = nil
    ) -> AsyncAuthenticator {
        AsyncDatabaseSessionAuthenticator<Self>(databaseID: databaseID)
    }
}

@available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
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

#endif

