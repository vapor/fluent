#if COCOAPODS
    @_exported import NodeCocoapods
#else
    @_exported import Node
#endif

public final class DatabaseContext: Context {
    public let database: Database

    public init(_ database: Database) {
        self.database = database
    }
}
