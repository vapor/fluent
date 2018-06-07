import Async
import Fluent
import Foundation

public final class User<D>: Model where D: QuerySupporting {
    /// See Model.Database
    public typealias Database = D

    /// See Model.ID
    public typealias ID = UUID

    /// See Model.idKey
    public static var idKey: IDKey { return \.id }

    /// See Timestampable.createdAtKey
    public static var createdAtKey: TimestampKey? { return \.createdAt }

    /// See Timestampable.updatedAtKey
    public static var updatedAtKey: TimestampKey? { return \.updatedAt }

    /// Foo's identifier
    var id: UUID?

    /// Name string
    var name: String

    /// Age int
    var age: Int

    /// Timestampable.createdAt
    public var createdAt: Date?

    /// Timestampable.updatedAt
    public var updatedAt: Date?

    /// Create a new foo
    init(id: ID? = nil, name: String, age: Int) {
        self.id = id
        self.name = name
        self.age = age
    }
}

// MARK: Relations

extension User {
    /// A relation to this user's pets.
    var pets: Children<User, Pet<Database>> {
        return children(\.ownerID)
    }
}

// MARK: Migration

internal struct UserMigration<D>: Migration
    where D: QuerySupporting & SchemaSupporting & MigrationSupporting
{
    /// See Migration.database
    typealias Database = D

    /// See Migration.prepare
    static func prepare(on connection: Database.Connection) -> Future<Void> {
        return Database.create(User<Database>.self, on: connection) { builder in
            builder.field(for: \User<Database>.id)
            builder.field(for: \User<Database>.name)
            builder.field(for: \User<Database>.age)
            builder.field(for: \User<Database>.createdAt)
            builder.field(for: \User<Database>.updatedAt)
        }
    }

    /// See Migration.revert
    static func revert(on connection: Database.Connection) -> Future<Void> {
        return Database.delete(User<Database>.self, on: connection)
    }
}
