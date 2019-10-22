import Vapor

public struct DatabaseSessions: Sessions {
    let database: Database
    
    public func createSession(_ data: SessionData, for request: Request) -> EventLoopFuture<SessionID> {
        let id = self.generateID()
        return Session(key: id, data: data)
            .create(on: self.database.with(request))
            .map { id }
    }
    
    public func readSession(_ sessionID: SessionID, for request: Request) -> EventLoopFuture<SessionData?> {
        return Session.query(on: self.database.with(request))
            .filter(\.$key == sessionID)
            .first()
            .map { $0?.data }
    }
    
    public func updateSession(_ sessionID: SessionID, to data: SessionData, for request: Request) -> EventLoopFuture<SessionID> {
        return Session.query(on: self.database.with(request))
            .filter(\.$key == sessionID)
            .set(\.$data, to: data)
            .update()
            .map { sessionID }
    }
    
    public func deleteSession(_ sessionID: SessionID, for request: Request) -> EventLoopFuture<Void> {
        return Session.query(on: self.database.with(request))
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

extension SessionID: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        try self.init(string: container.decode(String.self))
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.string)
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
