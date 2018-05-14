import Logging

/// Contains a single migration.
/// - note: we need this type for type erasing purposes.
internal struct MigrationContainer<D> where D: QuerySupporting {
    /// static database type info
    /// note: this is important
    typealias Database = D

    /// the closure for performing the migration
    var prepare: (Database.Connection) -> Future<Void>

    /// the closure for reverting the migration
    var revert: (Database.Connection) -> Future<Void>

    /// this migration's unique name
    var name: String

    /// creates a new migration container for a given migration type
    init<M>(_ migration: M.Type, name: String) where M: Migration, M.Database == D {
        self.prepare = M.prepare
        self.revert = M.revert
        self.name = name
    }

    /// creates a new migration container from closures.
    init(
        name: String,
        prepare: @escaping (Database.Connection) -> Future<Void>,
        revert: @escaping (Database.Connection) -> Future<Void>
    ) {
        self.prepare = prepare
        self.revert = revert
        self.name = name
    }

    /// Prepares the migration if it hasn't previously run.
    internal func prepareIfNeeded(batch: Int, on conn: Database.Connection, using container: Container) throws -> Future<Void> {
        return try hasPrepared(on: conn).flatMap { hasPrepared -> Future<Void> in
            guard !hasPrepared else {
                return .done(on: conn)
            }

            let log = try container.make(Logger.self)
            log.info("Preparing migration '\(self.name)'")
            return self.prepare(conn).flatMap(to: Void.self) {
                // create the migration log
                let log = MigrationLog<Database>(name: self.name, batch: batch)
                return MigrationLog<Database>
                    .query(on: conn)
                    .save(log)
                    .transform(to: ())
            }
        }
    }

    /// Reverts the migration if it was part of the supplied batch number.
    internal func revertIfNeeded(batch: Int, on conn: Database.Connection, using container: Container) throws -> Future<Void> {
        return try MigrationLog<Database>
            .query(on: conn)
            .filter(\.name == name)
            .filter(\.batch == batch)
            .first()
            .flatMap { mig in
                if mig != nil {
                    return try self.revertDeletingMetadata(on: conn, using: container)
                } else {
                    return .done(on: conn)
                }
            }
    }

    /// Reverts the migration if it has previously run.
    internal func revertIfNeeded(on conn: Database.Connection, using container: Container) throws -> Future<Void> {
        return try hasPrepared(on: conn).flatMap { hasPrepared in
            if hasPrepared {
                return try self.revertDeletingMetadata(on: conn, using: container)
            } else {
                return .done(on: conn)
            }
        }
    }

    func revertDeletingMetadata(on conn: Database.Connection, using container: Container) throws -> Future<Void> {
        let log = try container.make(Logger.self)
        log.info("Reverting migration '\(name)'")
        return revert(conn).flatMap {
            // delete the migration log
            return try MigrationLog<Database>
                .query(on: conn)
                .filter(\.name == self.name)
                .delete()
        }
    }

    /// returns true if the migration has already been prepared.
    internal func hasPrepared(on conn: Database.Connection) throws -> Future<Bool> {
        return try MigrationLog<Database>
            .query(on: conn)
            .filter(\.name == name)
            .first()
            .map { $0 != nil }
    }
}
