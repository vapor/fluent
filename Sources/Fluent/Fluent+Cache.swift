import NIOCore
import Foundation
import Vapor
import FluentKit

extension Application.Caches {
    public var fluent: any Cache {
        self.fluent(nil)
    }

    public func fluent(_ db: DatabaseID?) -> any Cache {
        FluentCache(id: db, database: self.application.db(db))
    }
}

extension Application.Caches.Provider {
    public static var fluent: Self {
        .fluent(nil)
    }

    public static func fluent(_ db: DatabaseID?) -> Self {
        .init {
            $0.caches.use { $0.caches.fluent(db) }
        }
    }
}

private struct FluentCache: Cache {
    let id: DatabaseID?
    let database: any Database
    
    init(id: DatabaseID?, database: any Database) {
        self.id = id
        self.database = database
    }
    
    func get<T>(_ key: String, as type: T.Type) -> EventLoopFuture<T?>
        where T: Decodable
    {
        CacheEntry.query(on: self.database)
            .filter(\.$key == key)
            .first()
            .flatMapThrowing { entry -> T? in
                if let entry = entry {
                    return try JSONDecoder().decode(T.self, from: Data(entry.value.utf8))
                } else {
                    return nil
                }
            }
    }
    
    func set(_ key: String, to value: (some Encodable)?) -> EventLoopFuture<Void> {
        if let value = value {
            do {
                let data = try JSONEncoder().encode(value)
                let entry = CacheEntry(
                    key: key,
                    value: String(decoding: data, as: UTF8.self)
                )
                return entry.create(on: self.database)
            } catch {
                return self.database.eventLoop.makeFailedFuture(error)
            }
        } else {
            return CacheEntry.query(on: self.database).filter(\.$key == key).delete()
        }
    }
    
    func `for`(_ request: Request) -> Self {
        .init(id: self.id, database: request.db(self.id))
    }
}

public final class CacheEntry: Model, @unchecked Sendable {
    public static let schema: String = "_fluent_cache"
    
    struct Create: Migration {
        func prepare(on database: any Database) -> EventLoopFuture<Void> {
            database.schema("_fluent_cache")
                .id()
                .field("key", .string, .required)
                .field("value", .string, .required)
                .unique(on: "key")
                .create()
        }
        
        func revert(on database: any Database) -> EventLoopFuture<Void> {
            database.schema("_fluent_cache").delete()
        }
    }

    public static var migration: any Migration {
        Create()
    }
    
    @ID(key: .id)
    public var id: UUID?
    
    @Field(key: "key")
    public var key: String
    
    @Field(key: "value")
    public var value: String
    
    public init() { }
    
    public init(id: UUID? = nil, key: String, value: String) {
        self.key = key
        self.value = value
    }
}
