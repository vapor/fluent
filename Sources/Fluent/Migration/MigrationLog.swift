import Async
import Foundation
import Service

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
    /// Prepares all of the supplied migrations that have not already run, assigning an incremented batch number.
    static func prepareBatch(
        _ migrations: [MigrationContainer<Database>],
        on conn: Database.Connection,
        using container: Container
    ) -> Future<Void> {
        return latestBatch(on: conn).flatMap(to: Void.self) { lastBatch in
            return migrations.map { migration in
                return { migration.prepareIfNeeded(batch: lastBatch + 1, on: conn, using: container) }
            }.syncFlatten(on: conn)
        }
    }

    /// Reverts all of the supplied migrations that ran in the most recent batch.
    static func revertBatch(
        _ migrations: [MigrationContainer<Database>],
        on conn: Database.Connection,
        using container: Container
    ) -> Future<Void> {
        return latestBatch(on: conn).flatMap(to: Void.self) { lastBatch in
            return migrations.reversed().map { migration in
                return { return migration.revertIfNeeded(batch: lastBatch, on: conn, using: container) }
            }.syncFlatten(on: conn)
        }
    }

    /// Reverts all of the supplied migrations (if they have been migrated).
    static func revertAll(
        _ migrations: [MigrationContainer<Database>],
        on conn: Database.Connection,
        using container: Container
    ) -> Future<Void> {
        return migrations.reversed().map { migration in
            return { return migration.revertIfNeeded(on: conn, using: container) }
        }.syncFlatten(on: conn)
    }

    /// Returns the latest batch number. Returns 0 if no batches have run yet.
    static func latestBatch(on conn: Database.Connection) -> Future<Int> {
        return Future.flatMap(on: conn) {
            return try conn.query(MigrationLog<Database>.self)
                .sort(\MigrationLog<Database>.batch, .descending)
                .first()
                .map(to: Int.self) { $0?.batch ?? 0 }
        }
    }

}

extension MigrationLog where D: SchemaSupporting {
    /// Prepares the connection for storing migration logs.
    /// note: this is unlike other migrations since we are checking
    /// for an error instead of asking if the migration has already prepared.
    internal static func prepareMetadata(on conn: Database.Connection) -> Future<Void> {
        let promise = conn.eventLoop.newPromise(Void.self)

        conn.query(MigrationLog<Database>.self).count().do { count in
            promise.succeed()
        }.catch { err in
            // table needs to be created
            prepare(on: conn).cascade(promise: promise)
        }

        return promise.futureResult
    }

    /// For parity, reverts the migration metadata.
    /// This simply calls the migration revert function.
    internal static func revertMetadata(on connection: Database.Connection) -> Future<Void> {
        return self.revert(on: connection)
    }
}
