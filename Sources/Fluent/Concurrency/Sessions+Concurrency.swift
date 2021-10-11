#if compiler(>=5.5) && canImport(_Concurrency)
import NIOCore
import Vapor

@available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
extension Model where Self: SessionAuthenticatable, Self.SessionID == Self.IDValue {
    public static func asyncSessionAuthenticator(
        _ databaseID: DatabaseID? = nil
    ) -> AsyncAuthenticator {
        AsyncDatabaseSessionAuthenticator<Self>(databaseID: databaseID)
    }
}

private struct DatabaseSessions: SessionDriver {
    let databaseID: DatabaseID?
    
    init(databaseID: DatabaseID? = nil) {
        self.databaseID = databaseID
    }
    
    func createSession(_ data: SessionData, for request: Request) -> EventLoopFuture<SessionID> {
        let id = self.generateID()
        return SessionRecord(key: id, data: data)
            .create(on: request.db(self.databaseID))
            .map { id }
    }
    
    func readSession(_ sessionID: SessionID, for request: Request) -> EventLoopFuture<SessionData?> {
        SessionRecord.query(on: request.db(self.databaseID))
            .filter(\.$key == sessionID)
            .first()
            .map { $0?.data }
    }
    
    func updateSession(_ sessionID: SessionID, to data: SessionData, for request: Request) -> EventLoopFuture<SessionID> {
        SessionRecord.query(on: request.db(self.databaseID))
            .filter(\.$key == sessionID)
            .set(\.$data, to: data)
            .update()
            .map { sessionID }
    }
    
    func deleteSession(_ sessionID: SessionID, for request: Request) -> EventLoopFuture<Void> {
        SessionRecord.query(on: request.db(self.databaseID))
            .filter(\.$key == sessionID)
            .delete()
    }
    
    private func generateID() -> SessionID {
        var bytes = Data()
        for _ in 0..<32 {
            bytes.append(.random(in: .min ..< .max))
        }
        return .init(string: bytes.base64EncodedString())
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

