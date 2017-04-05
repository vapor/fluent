/// Represents an abstract database query.
public final class Query<E: Entity> {
    /// The type of action to perform
    /// on the data. Defaults to `.fetch`
    public var action: Action

    /// An array of filters to apply
    ///during the query's action.
    public var filters: [RawOr<Filter>]

    /// Optional data to be used during
    ///`.create` or `.modify` actions.
    public var data: [RawOr<String>: RawOr<Node>]
    
    /// Optional keys to access during
    /// `.fetch` actions
    public var keys: [RawOr<String>]

    /// Optionally limit the amount of
    /// entities affected by the action.
    public var limits: [RawOr<Limit>]

    /// An array of sorts that will
    /// be applied to the results.
    public var sorts: [RawOr<Sort>]

    /// An array of joins: other entities
    /// that will be queried during this query's
    /// execution.
    public var joins: [RawOr<Join>]

    private(set) lazy var context: RowContext = {
        let context = RowContext()
        context.database = self.database
        return context
    }()

    /// If true, soft deleted entities will be 
    /// included (given the Entity type is SoftDeletable)
    internal var includeSoftDeleted: Bool
    
    /// If true, uses appropriate distinct modifiers
    /// on fetch and counts to return only distinct
    /// results for this query.
    public var distinct: Bool

    /// Creates a new `Query` with the
    /// `Model`'s database.
    public init(_ database: Database) {
        filters = []
        action = .fetch
        self.database = database
        joins = []
        limits = []
        sorts = []
        distinct = false
        includeSoftDeleted = false
        data = [:]
        keys = []
    }

    /// Performs the Query returning the raw
    /// Node data from the driver.
    @discardableResult
    public func raw() throws -> Node {
        return try database.query(.some(self))
    }

    //MARK: Internal

    /// The database to which the query
    /// should be sent.
    internal let database: Database
}

extension Query: QueryRepresentable {
    /// Conformance to `QueryRepresentable`
    public func makeQuery() -> Query<E> {
        return self
    }
}
