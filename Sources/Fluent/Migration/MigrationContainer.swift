import Async
import Logging
import Service

/// Contains a single migration.
/// note: we need this type for type erasing purposes.
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
    internal func prepareIfNeeded(
        batch: Int,
        on connection: Database.Connection,
        using container: Container
    ) -> Future<Void> {
        return hasPrepared(on: connection).flatMap(to: Void.self) { hasPrepared in
            if hasPrepared {
                return .done(on: connection)
            } else {
                let log = try container.make(Logger.self)
                log.info("Preparing migration '\(self.name)'")
                return self.prepare(connection).flatMap(to: Void.self) {
                    // create the migration log
                    let log = MigrationLog<Database>(name: self.name, batch: batch)
                    return MigrationLog<Database>
                        .query(on: Future.map(on: connection) { connection })
                        .save(log)
                        .transform(to: ())
                }
            }
        }
    }

    /// Reverts the migration if it was part of the supplied batch number.
    internal func revertIfNeeded(batch: Int, on connection: Database.Connection, using container: Container) -> Future<Void> {
        return Future.flatMap(on: connection) {
            return try MigrationLog<Database>
                .query(on: connection)
                .filter(\MigrationLog<Database>.name, .equals, .data(self.name))
                .filter(\MigrationLog<Database>.batch, .equals, .data(batch))
                .first()
        }.flatMap(to: Void.self) { mig in
            if mig != nil {
                return self.revertDeletingMetadata(on: connection, using: container)
            } else {
                return .done(on: connection)
            }
        }
    }

    /// Reverts the migration if it has previously run.
    internal func revertIfNeeded(on connection: Database.Connection, using container: Container) -> Future<Void> {
        return hasPrepared(on: connection).flatMap(to: Void.self) { hasPrepared in
            if hasPrepared {
                return self.revertDeletingMetadata(on: connection, using: container)
            } else {
                return .done(on: connection)
            }
        }
    }

    func revertDeletingMetadata(on connection: Database.Connection, using container: Container) -> Future<Void> {
        return Future.flatMap(on: connection) {
            let log = try container.make(Logger.self)
            log.info("Reverting migration '\(self.name)'")
            return self.revert(connection).flatMap(to: Void.self) { _ in
                // delete the migration log
                return try MigrationLog<Database>
                    .query(on: connection)
                    .filter(\.name, .equals, .data(self.name))
                    .delete()
            }
        }
    }

    /// returns true if the migration has already been prepared.
    internal func hasPrepared(on connection: Database.Connection) -> Future<Bool> {
        return Future.flatMap(on: connection) {
            return try MigrationLog<Database>
                .query(on: Future.map(on: connection) { connection })
                .filter(\.name, .equals, .data(self.name))
                .first()
                .map(to: Bool.self) { $0 != nil }
        }
    }
}
