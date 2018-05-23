/// Supports running `Migration`s.
public protocol MigrationSupporting: QuerySupporting {
    /// Prepares this connection for handling `Migration`s.
    ///
    /// - parameters:
    ///     - conn: Connection to prepare.
    /// - returns: A future that will be completed when the preparation is finished.
    static func prepareMigrationMetadata(on conn: Connection) -> Future<Void>
}
