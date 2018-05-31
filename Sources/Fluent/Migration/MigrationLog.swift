/// Stores information about `Migration`s that have been run.
/// This information is used to determine which migrations need to be run
/// when the app boots. It is also used to determine which migrations to revert when
/// using the `RevertCommand`.
public final class MigrationLog<Database>: Model where Database: QuerySupporting {
    /// See `Model`.
    public typealias ID = UUID

    /// See `Model`.
    public static var entity: String { return "fluent" }

    /// See `Model`.
    public static var idKey: IDKey { return \.id }

    /// See `Timestampable`.
    public static var createdAtKey: TimestampKey? { return \.createdAt }

    /// See `Timestampable`.
    public static var updatedAtKey: TimestampKey? { return \.updatedAt }

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
