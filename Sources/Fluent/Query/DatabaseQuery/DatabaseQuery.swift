/// A query that can be sent to a Fluent database.
public struct DatabaseQuery<Database> where Database: QuerySupporting {
    /// Table / collection to query.
    public let entity: String

    /// CURD action to perform on the database.
    public var action: Action

    /// Aggregates / computed methods.
    public var aggregates: [Aggregate]

    /// Optional model data to create or update.
    /// Defaults to an empty dictionary.
    public var data: [Database.QueryField: Database.QueryData]

    /// Result set will be limited by these filters.
    public var filters: [Filter]
    
    /// One or more group bys to filter by.
    public var groups: [GroupBy]

    /// If `true`, the query will only select distinct rows.
    public var isDistinct: Bool

    /// Limits and offsets the amount of results.
    public var range: Range?

    /// Sorts to be applied to the results.
    public var sorts: [Sort]

    /// Allows extensions to store properties.
    public var extend: Extend

    /// Create a new database query.
    public init(entity: String) {
        self.entity = entity
        self.action = .read
        self.filters = []
        self.sorts = []
        self.groups = []
        self.aggregates = []
        self.isDistinct = false
        self.data = [:]
        self.range = nil
        self.extend = [:]
    }
}
