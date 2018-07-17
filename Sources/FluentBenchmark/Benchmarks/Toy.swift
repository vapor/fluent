import Async
import Fluent
import Foundation

public struct Toy<Database>: Model where Database: QuerySupporting {
    /// See Model.idKey
    public static var idKey: WritableKeyPath<Toy<Database>, UUID?> { return \.id }

    /// Foo's identifier
    var id: UUID?

    /// Name string
    var name: String

    /// Create a new foo
    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
}

// MARK: Relations

extension Toy where Database: JoinSupporting {
    /// A relation to this toy's pets.
    var pets: Siblings<Toy, Pet<Database>, PetToy<Database>> {
        return self.siblings()
    }
}

// MARK: Migration

internal struct ToyMigration<Database>: Migration where Database: QuerySupporting & SchemaSupporting & MigrationSupporting {
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
