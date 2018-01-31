import Async
import Foundation

/// Represents a migration that has succesfully ran.
final class MigrationLog<D>: Model, Timestampable where D: QuerySupporting {
    /// See Model.Database
    typealias Database = D

    /// See Model.dbID
    static var database: DatabaseIdentifier<D> {
        return .init("migration")
    }

    /// See Model.ID
    typealias ID = UUID

    /// See Model.entity
    static var entity: String { return "fluent" }

    /// See Model.idKeyPath
    static var idKey: IDKey { return \.id }

    /// See Timestampable.createdAtKey
    static var createdAtKey: CreatedAtKey { return \.createdAt }

    /// See Timestampable.updatedAtKey
    static var updatedAtKey: UpdatedAtKey { return \.updatedAt }

    /// See Model.id
    var id: UUID?

    /// The unique name of the migration.
    var name: String

    /// The batch number.
    var batch: Int

    /// See Timestampable.createdAt
    var createdAt: Date?

    /// See Timestampable.updatedAt
    var updatedAt: Date?

    /// Create a new migration log
    init(id: UUID? = nil, name: String, batch: Int) {
        self.id = id
        self.name = name
        self.batch = batch
    }
}

/// MARK: Migration
extension MigrationLog: Migration where D: SchemaSupporting { }

/// MARK: Internal

extension MigrationLog {
    /// Returns the latest batch number.
    /// note: returns 0 if no batches have run yet.
    internal static func latestBatch(on conn: Database.Connection) -> Future<Int> {
        return conn.query(MigrationLog<Database>.self)
            .sort(\MigrationLog<Database>.batch, .descending)
            .first()
            .map(to: Int.self) { $0?.batch ?? 0 }
    }
}

extension MigrationLog where D: SchemaSupporting {
    /// Prepares the connection for storing migration logs.
    /// note: this is unlike other migrations since we are checking
    /// for an error instead of asking if the migration has already prepared.
    internal static func prepareMetadata(on conn: Database.Connection) -> Future<Void> {
        let promise = Promise(Void.self)

        conn.query(MigrationLog<Database>.self).count().do { count in
            promise.complete()
        }.catch { err in
            // table needs to be created
            prepare(on: conn).chain(to: promise)
        }

        return promise.future
    }

    /// For parity, reverts the migration metadata.
    /// This simply calls the migration revert function.
    internal static func revertMetadata(on connection: Database.Connection) -> Future<Void> {
        return self.revert(on: connection)
    }
}
