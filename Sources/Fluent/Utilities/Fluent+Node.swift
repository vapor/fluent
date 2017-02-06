@_exported import Node

public struct DatabaseContext: Context {
    public let database: Database

    public init(_ database: Database) {
        self.database = database
    }
}
