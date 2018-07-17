import Async
import Fluent
import Foundation

public final class Pet<Database>: Model where Database: QuerySupporting {
    /// See Model.idKey
    public static var idKey: WritableKeyPath<Pet<Database>, UUID?> { return \.id }

    /// Foo's identifier
    var id: UUID?

    /// Name string
    var name: String

    /// Age int
    var ownerID: UUID?

    /// Creates a new `Pet`
    init(id: UUID? = nil, name: String, ownerID: UUID?) {
        self.id = id
        self.name = name
        self.ownerID = ownerID
    }
}

// MARK: Relations

extension Pet {
    /// A relation to this pet's owner.
    var owner: Parent<Pet, User<Database>>? {
        return parent(\.ownerID)
    }
}

extension Pet where Database: JoinSupporting {
    /// A relation to this pet's toys.
    var toys: Siblings<Pet, Toy<Database>, PetToy<Database>> {
        return siblings()
    }
}

// MARK: Migration

extension Pet: Migration, AnyMigration where Database: SchemaSupporting & MigrationSupporting {
    /// See `Migration.prepare(on:)`
    public static func prepare(on connection: Database.Connection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.ownerID, to: \User<Database>.id)
        }
    }
}
