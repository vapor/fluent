import Foundation
import NIOCore
import Vapor
import FluentKit

extension Application.Fluent {
    public var sessions: Sessions {
        .init(fluent: self)
    }

    public struct Sessions {
        let fluent: Application.Fluent
    }
}

public protocol ModelSessionAuthenticatable: Model, SessionAuthenticatable
    where Self.SessionID == Self.IDValue
{ }

extension ModelSessionAuthenticatable {
    public var sessionID: SessionID {
        guard let id = self.id else {
            fatalError("Cannot persist unsaved model to session.")
        }
        return id
    }
}

extension Model where Self: SessionAuthenticatable, Self.SessionID == Self.IDValue {
    public static func sessionAuthenticator(
        _ databaseID: DatabaseID? = nil
    ) -> any Authenticator {
        DatabaseSessionAuthenticator<Self>(databaseID: databaseID)
    }
}

extension Application.Fluent.Sessions {
    public func driver(_ databaseID: DatabaseID? = nil) -> any SessionDriver {
        DatabaseSessions(databaseID: databaseID)
    }
}

extension Application.Sessions.Provider {
    public static var fluent: Self {
        .fluent(nil)
    }

    public static func fluent(_ databaseID: DatabaseID?) -> Self {
        .init {
            $0.sessions.use { $0.fluent.sessions.driver(databaseID) }
        }
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

private struct DatabaseSessionAuthenticator<User>: SessionAuthenticator
    where User: SessionAuthenticatable, User: Model, User.SessionID == User.IDValue
{
    let databaseID: DatabaseID?

    func authenticate(sessionID: User.SessionID, for request: Request) -> EventLoopFuture<Void> {
        User.find(sessionID, on: request.db(self.databaseID)).map {
            if let user = $0 {
                request.auth.login(user)
            }
        }
    }
}

public final class SessionRecord: Model, @unchecked Sendable {
    public static let schema = "_fluent_sessions"

    struct Create: Migration {
        func prepare(on database: any Database) -> EventLoopFuture<Void> {
            database.schema("_fluent_sessions")
                .id()
                .field("key", .string, .required)
                .field("data", .json, .required)
                .unique(on: "key")
                .create()
        }

        func revert(on database: any Database) -> EventLoopFuture<Void> {
            database.schema("_fluent_sessions").delete()
        }
    }

    public static var migration: any Migration {
        Create()
    }
    
    @ID(key: .id)
    public var id: UUID?
    
    @Field(key: "key")
    public var key: SessionID
    
    @Field(key: "data")
    public var data: SessionData
    
    public init() { }
    
    public init(id: UUID? = nil, key: SessionID, data: SessionData) {
        self.id = id
        self.key = key
        self.data = data
    }
}
