/// MARK: Migration
extension MigrationLog: Migration where D: SchemaSupporting { }


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
