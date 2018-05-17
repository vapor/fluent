/// Represents a migration that has been prepared.
public final class MigrationLog<D>: Model, Timestampable where D: QuerySupporting {
    /// See `Model`.
    public typealias Database = D

    /// See `Model`.
    public typealias ID = UUID

    /// See `Model`.
    public static var entity: String { return "fluent" }

    /// See `Model`.
    public static var idKey: IDKey { return \.id }

    /// See `Timestampable`.
    public static var createdAtKey: CreatedAtKey { return \.createdAt }

    /// See `Timestampable`.
    public static var updatedAtKey: UpdatedAtKey { return \.updatedAt }

    /// See `Model`.
    public var id: UUID?

    /// The unique name of the migration.
    public var name: String

    /// The batch number.
    public var batch: Int

    /// When this log was created.
    public var createdAt: Date?

    /// When this log was last updated.
    public var updatedAt: Date?

    /// Create a new `MigrationLog`.
    public init(id: UUID? = nil, name: String, batch: Int) {
        self.id = id
        self.name = name
        self.batch = batch
    }
}

/// MARK: Internal

extension MigrationLog {
    /// Prepares all of the supplied migrations that have not already run, assigning an incremented batch number.
    public static func prepareBatch(_ migrations: [MigrationContainer<Database>], on conn: Database.Connection, using container: Container) throws -> Future<Void> {
        return try latestBatch(on: conn).flatMap { lastBatch in
            return migrations.map { migration in
                return { migration.prepareIfNeeded(batch: lastBatch + 1, on: conn, using: container) }
            }.syncFlatten(on: conn)
        }
    }

    /// Reverts all of the supplied migrations that ran in the most recent batch.
    public static func revertBatch(_ migrations: [MigrationContainer<Database>], on conn: Database.Connection, using container: Container) throws -> Future<Void> {
        return try latestBatch(on: conn).flatMap { lastBatch in
            return migrations.reversed().map { migration in
                return { return migration.revertIfNeeded(batch: lastBatch, on: conn, using: container) }
            }.syncFlatten(on: conn)
        }
    }

    /// Reverts all of the supplied migrations (if they have been migrated).
    public static func revertAll(_ migrations: [MigrationContainer<Database>], on conn: Database.Connection, using container: Container) -> Future<Void> {
        return migrations.reversed().map { migration in
            return { return migration.revertIfNeeded(on: conn, using: container) }
        }.syncFlatten(on: conn)
    }

    /// Returns the latest batch number. Returns 0 if no batches have run yet.
    public static func latestBatch(on conn: Database.Connection) throws -> Future<Int> {
        return conn.query(MigrationLog<Database>.self)
            .sort(\.batch, .fluentDescending)
            .first()
            .map { $0?.batch ?? 0 }
    }

}
