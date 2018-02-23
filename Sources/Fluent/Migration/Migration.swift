import CodableKit
import Async

/// Declares a database migration.
public protocol Migration {
    /// The type of database this migration can run on.
    /// Migrations require a query executor to work correctly
    /// as they must be able to query the MigrationLog model.
    associatedtype Database: Fluent.Database

    /// Runs this migration's changes on the database.
    /// This is usually creating a table, or altering an existing one.
    static func prepare(on connection: Database.Connection) -> Future<Void>

    /// Reverts this migration's changes on the database.
    /// This is usually dropping a created table. If it is not possible
    /// to revert the changes from this migration, complete the future
    /// with an error.
    static func revert(on connection: Database.Connection) -> Future<Void>
}

/// MARK: Auto Migration

extension Model where Database: SchemaSupporting {
    /// Automatically adds `SchemaField`s for each of this `Model`s properties.
    public static func addProperties(to builder: SchemaCreator<Self>) throws {
        let idCodingPath = Self.codingPath(forKey: idKey)
        let properties = Self.properties()

        for property in properties {
            guard property.codingPath.count == 1 else {
                continue
            }

            let field = try SchemaField<Database>(
                name: property.codingPath[0].stringValue,
                type: Database.fieldType(for: property.type),
                isOptional: property.isOptional,
                isIdentifier: property.codingPath.equals(idCodingPath)
            )
            builder.schema.addFields.append(field)
        }
    }
}

/// MARK: Schema Supporting

extension Model where Self: Migration, Database: SchemaSupporting {
    /// See `Migration.prepare(on:)`
    public static func prepare(on connection: Database.Connection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
        }
    }

    /// See `Migration.revert(on:)`
    public static func revert(on connection: Database.Connection) -> Future<Void> {
        return Database.delete(self, on: connection)
    }
}

/// MARK: Utils

extension Array where Element == CodingKey {
    /// Returns true if the two coding keys are equivalent
    fileprivate func equals(_ other: [CodingKey]) -> Bool {
        guard count == other.count else {
            return false
        }

        for a in self {
            for b in other {
                guard a.stringValue == b.stringValue else {
                    return false
                }
            }
        }

        return true
    }
}
