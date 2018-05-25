import Async
import Fluent
import Foundation

public struct Toy<D>: Model where D: QuerySupporting {
    /// See Model.Database
    public typealias Database = D

    /// See Model.ID
    public typealias ID = UUID

    /// See Model.name
    public static var name: String {
        return "toy"
    }

    /// See Model.idKey
    public static var idKey: IDKey { return \.id }

    /// Foo's identifier
    var id: ID?

    /// Name string
    var name: String

    /// Create a new foo
    init(id: ID? = nil, name: String) {
        self.id = id
        self.name = name
    }
}

// MARK: Relations

extension Toy where Database: JoinSupporting {
    /// A relation to this toy's pets.
    var pets: Siblings<Toy, Pet<Database>, PetToy<Database>> {
        return siblings()
    }
}

// MARK: Migration

internal struct ToyMigration<D>: Migration where D: QuerySupporting & SQLSupporting {
    /// See Migration.database
    typealias Database = D

    /// See Migration.prepare
    static func prepare(on connection: Database.Connection) -> Future<Void> {
        return Database.create(Toy<Database>.self, on: connection) { builder in
            builder.field(for: \Toy<Database>.id)
            builder.field(for: \Toy<Database>.name)
        }
    }

    /// See Migration.revert
    static func revert(on connection: Database.Connection) -> Future<Void> {
        return Database.delete(Toy<Database>.self, on: connection)
    }
}
