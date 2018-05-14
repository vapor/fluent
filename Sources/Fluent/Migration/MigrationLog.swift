/// Represents a migration that has been prepared.
final class MigrationLog<D>: Model, Timestampable where D: QuerySupporting {
    /// See `Model`.
    typealias Database = D

    /// See `Model`.
    typealias ID = UUID

    /// See `Model`.
    static var entity: String { return "fluent" }

    /// See `Model`.
    static var idKey: IDKey { return \.id }

    /// See `Timestampable`.
    static var createdAtKey: CreatedAtKey { return \.createdAt }

    /// See `Timestampable`.
    static var updatedAtKey: UpdatedAtKey { return \.updatedAt }

    /// See `Model`.
    var id: UUID?

    /// The unique name of the migration.
    var name: String

    /// The batch number.
    var batch: Int

    /// When this log was created.
    var createdAt: Date?

    /// When this log was last updated.
    var updatedAt: Date?

    /// Create a new `MigrationLog`.
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
    static func prepareBatch(_ migrations: [MigrationContainer<Database>], on conn: Database.Connection, using container: Container) throws -> Future<Void> {
        return try latestBatch(on: conn).flatMap { lastBatch in
            return migrations.map { migration in
                return { try migration.prepareIfNeeded(batch: lastBatch + 1, on: conn, using: container) }
            }.syncFlatten(on: conn)
        }
    }

    /// Reverts all of the supplied migrations that ran in the most recent batch.
    static func revertBatch(_ migrations: [MigrationContainer<Database>], on conn: Database.Connection, using container: Container) throws -> Future<Void> {
        return try latestBatch(on: conn).flatMap { lastBatch in
            return migrations.reversed().map { migration in
                return { return try migration.revertIfNeeded(batch: lastBatch, on: conn, using: container) }
            }.syncFlatten(on: conn)
        }
    }

    /// Reverts all of the supplied migrations (if they have been migrated).
    static func revertAll(_ migrations: [MigrationContainer<Database>], on conn: Database.Connection, using container: Container) -> Future<Void> {
        return migrations.reversed().map { migration in
            return { return try migration.revertIfNeeded(on: conn, using: container) }
        }.syncFlatten(on: conn)
    }

    /// Returns the latest batch number. Returns 0 if no batches have run yet.
    static func latestBatch(on conn: Database.Connection) throws -> Future<Int> {
        return try conn.query(MigrationLog<Database>.self)
            .sort(\.batch, .descending)
            .first()
            .map { $0?.batch ?? 0 }
    }

}

extension MigrationLog where D: SchemaSupporting {
    /// Prepares the connection for storing migration logs.
    /// - note: this is unlike other migrations since we are checking
    ///         for an error instead of asking if the migration has already prepared.
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
