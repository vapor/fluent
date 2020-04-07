import Vapor

extension Application.Fluent {
    public var sessions: Sessions {
        .init(fluent: self)
    }

    public struct Sessions {
        let fluent: Application.Fluent
    }
}

extension Application.Fluent.Sessions {
    public func middleware<User>(
        for user: User.Type,
        databaseID: DatabaseID? = nil
    ) -> Middleware
        where User: SessionAuthenticatable, User: Model, User.SessionID == User.IDValue
    {
        DatabaseSessionAuthenticator<User>(databaseID: databaseID).middleware()
    }

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
        return Session(key: id, data: data)
            .create(on: request.db(self.databaseID))
            .map { id }
    }
    
    func readSession(_ sessionID: SessionID, for request: Request) -> EventLoopFuture<SessionData?> {
        return Session.query(on: request.db(self.databaseID))
            .filter(\.$key == sessionID)
            .first()
            .map { $0?.data }
    }
    
    func updateSession(_ sessionID: SessionID, to data: SessionData, for request: Request) -> EventLoopFuture<SessionID> {
        return Session.query(on: request.db(self.databaseID))
            .filter(\.$key == sessionID)
            .set(\.$data, to: data)
            .update()
            .map { sessionID }
    }
    
    func deleteSession(_ sessionID: SessionID, for request: Request) -> EventLoopFuture<Void> {
        return Session.query(on: request.db(self.databaseID))
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

    func resolve(sessionID: User.SessionID, for request: Request) -> EventLoopFuture<User?> {
        User.find(sessionID, on: request.db)
    }
}

public final class Session: Model {
    public static let schema = "sessions"
    
    @ID(key: "id")
    public var id: UUID?
    
    @Field(key: "key")
    public var key: SessionID
    
    @Field(key: "data")
    public var data: SessionData
    
    public init() {
        
    }
    
    public init(id: UUID? = nil, key: SessionID, data: SessionData) {
        self.id = id
        self.key = key
        self.data = data
    }
}

public struct CreateSession: Migration {
    
    public init() {
        
    }
    
    public func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("sessions")
            .field("id", .uuid, .identifier(auto: false))
            .field("key", .string, .required)
            .field("data", .json, .required)
            .create()
    }
    
    public func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("sessions").delete()
    }
}
