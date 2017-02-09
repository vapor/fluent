@_exported import Node

public final class DatabaseContext: Context {
    public let database: Database

    public init(_ database: Database) {
        self.database = database
    }
}
