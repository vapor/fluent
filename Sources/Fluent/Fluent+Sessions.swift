import Vapor

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
    ) -> Authenticator {
        DatabaseSessionAuthenticator<Self>(databaseID: databaseID)
    }
}

extension Application.Fluent.Sessions {
    public func driver(_ databaseID: DatabaseID? = nil) -> SessionDriver {
        DatabaseSessions(databaseID: databaseID)
    }
}

extension Application.Sessions.Provider {
    public static var fluent: Self {
        return .fluent(nil)
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
            .map { $0?.session }
    }
    
    func updateSession(_ sessionID: SessionID, to data: SessionData, for request: Request) -> EventLoopFuture<SessionID> {
        let query = SessionRecord.query(on: request.db(self.databaseID))
                                 .filter(\.$key == sessionID)
        
        if data.userStorageChanged { query.set(\.$storage, to: data.storage) }
        if data.appStorageChanged { query.set(\.$appStorage, to: data.appStorage) }
        if data.expiryChanged { query.set(\.$expiration, to: data.expiration) }
        
        return query.update().map { sessionID }
    }
    
    func deleteSession(_ sessionID: SessionID, for request: Request) -> EventLoopFuture<Void> {
        SessionRecord.query(on: request.db(self.databaseID))
            .filter(\.$key == sessionID)
            .delete()
    }
    
    func deleteExpiredSessions(before: SessionData.Expiration, on request: Request) -> EventLoopFuture<Void> {
        SessionRecord.query(on: request.db(self.databaseID))
            .filter(\.$expiration <= before)
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
        User.find(sessionID, on: request.db).map {
            if let user = $0 {
                request.auth.login(user)
            }
        }
    }
}

public final class SessionRecord: Model {
    public static let schema = "_fluent_sessions"

    private struct _Migration: Migration {
        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema(SessionRecord.schema)
                .id()
                .field("key", .string, .required)
                .field("storage", .json, .required)
                .field("appStorage", .json, .required)
                .field("expiration", .datetime, .required)
                .unique(on: "key")
                .create()
        }

        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema(SessionRecord.schema).delete()
        }
    }

    public static var migration: Migration {
        _Migration()
    }
    
    @ID(key: .id)
    public var id: UUID?
    
    @Field(key: "key")
    public var key: SessionID
    
    @Field(key: "storage")
    public var storage: SessionData.Data
    
    @Field(key: "appStorage")
    public var appStorage: SessionData.Data
    
    @Field(key: "expiration")
    public var expiration: SessionData.Expiration
    
    public init() { }
    
    public init(id: UUID? = nil, key: SessionID, data: SessionData) {
        self.id = id
        self.key = key
        self.storage = data.storage
        self.appStorage = data.appStorage
        self.expiration = data.expiration
    }
    
    public var session: SessionData {
        .init(storage, app: appStorage, expiration: expiration)
    }
}
