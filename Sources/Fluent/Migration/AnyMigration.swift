/// Type-erased wrapper around a single `Migration`.
public protocol AnyMigration {
    /// Closure for preparing the migration.
    static func migrationPrepare(any: Any) -> Future<Void>

    /// Closure for reverting the migration.
    static func migrationRevert(any: Any) -> Future<Void>

    /// Default, unique name for this migration. This will be used identify the migration in the logs and history metadata.
    static var migrationName: String { get }
}

// MARK: Optional

extension AnyMigration where Self: Migration {
    /// See `Migration`.
    public static var migrationName: String {
        let _type = "\(type(of: self))"
        return _type.components(separatedBy: ".Type").first ?? _type
    }

    /// See `Migration`.
    public static func migrationPrepare(any: Any) -> Future<Void> {
        return prepare(on: convert(any: any))
    }

    /// See `Migration`.
    public static func migrationRevert(any: Any) -> Future<Void> {
        return revert(on: convert(any: any))
    }

    // MARK: Private

    /// Converts type-erased `DatabaseConnection` to `Database.Connection`.
    private static func convert(any: Any) -> Database.Connection {
        guard let conn = any as? Database.Connection else {
            fatalError("Unexpected database connection: \(any). Expected \(Database.Connection.self).")
        }
        return conn
    }
}
