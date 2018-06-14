import Async
import Fluent
import Foundation

/// A pivot between pet and toy.
public final class PetToy<Database>: ModifiablePivot where Database: QuerySupporting {
    /// See Pivot.Left
    public typealias Left = Pet<Database>

    /// See Pivot.Right
    public typealias Right = Toy<Database>

    /// See Model.idKey
    public static var idKey: WritableKeyPath<PetToy<Database>, UUID?> { return \.id }

    /// See Pivot.leftIDKey
    public static var leftIDKey: WritableKeyPath<PetToy<Database>, UUID> { return \.petID }

    /// See Pivot.rightIDKey
    public static var rightIDKey: WritableKeyPath<PetToy<Database>, UUID> { return \.toyID }

    /// PetToy's identifier
    var id: UUID?

    /// The pet's id
    var petID: UUID

    /// The toy's id
    var toyID: UUID

    /// See ModifiablePivot.init
    public init(_ pet: Pet<Database>, _ toy: Toy<Database>) throws {
        petID = try pet.requireID()
        toyID = try toy.requireID()
    }
}

internal struct PetToyMigration<Database>: Migration where Database: QuerySupporting & SchemaSupporting & MigrationSupporting {
    /// See Migration.prepare
    static func prepare(on connection: Database.Connection) -> Future<Void> {
        return Database.create(PetToy<Database>.self, on: connection) { builder in
            builder.field(for: \PetToy<Database>.id)
            builder.field(for: \PetToy<Database>.petID)
            builder.field(for: \PetToy<Database>.toyID)
        }
    }

    /// See Migration.revert
    static func revert(on connection: Database.Connection) -> Future<Void> {
        return Database.delete(PetToy<Database>.self, on: connection)
    }
}
