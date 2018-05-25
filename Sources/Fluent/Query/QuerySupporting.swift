/// Capable of executing a database queries as defined by `Query`.
public protocol QuerySupporting: Database {
    /// Associated `Query` type. Instances of this type will be supplied to `queryExecute(...)`.
    associatedtype Query

    /// Creates a new instance of self using the supplied entity `String`.
    static func query(_ entity: String) -> Query

    /// Type returned by this query when reading data. Result set type.
    /// Decoded by `queryDecode(...)` method on `QuerySupporting`.
    associatedtype Output
    
    /// Executes the supplied query on the database connection. Results should be streamed into the handler.
    /// When the query is finished, the returned future should be completed.
    ///
    /// - parameters:
    ///     - query: Query to execute.
    ///     - handler: Handles query output.
    ///     - conn: Database connection to use.
    /// - returns: A future that will complete when the query has finished.
    static func queryExecute(_ query: Query, on conn: Connection, into handler: @escaping (Output, Connection) throws -> ()) -> Future<Void>

    /// Decodes a decodable type `D` from this database's output.
    ///
    /// - parameters:
    ///     - output: Query output to decode.
    ///     - entity: Entity to decode from (table or collection name).
    ///     - decodable: Decodable type to create.
    /// - returns: Decoded type.
    static func queryDecode<D>(_ output: Output, entity: String, as decodable: D.Type) throws -> D
        where D: Decodable

    /// Encodes an encodable object into this database's input.
    ///
    /// - parameters:
    ///     - encodable: Item to encode.
    ///     - entity: Entity to encode to (table or collection name).
    /// - returns: Encoded query input.
    static func queryEncode<E>(_ encodable: E, entity: String) throws -> QueryData
        where E: Encodable

    /// This method will be called by Fluent during `Model` lifecycle events.
    /// This gives the database a chance to interact with the model before Fluent encodes it.
    static func modelEvent<M>(event: ModelEvent, model: M, on conn: Connection) -> Future<M>
        where M: Model, M.Database == Self

    // MARK: Action

    /// Specific query type, usually create, read, update, delete.
    associatedtype QueryAction

    static var queryActionCreate: QueryAction { get }
    static var queryActionRead: QueryAction { get }
    static var queryActionUpdate: QueryAction { get }
    static var queryActionDelete: QueryAction { get }
    static func queryActionIsCreate(_ action: QueryAction) -> Bool
    static func queryActionApply(_ action: QueryAction, to query: inout Query)

    // MARK: Aggregate

    /// Aggregates generate data for every row of returned data. They usually aggregate data for a single field,
    /// but can also operate over most fields. When an aggregate is applied to a query, the aggregate method will apply
    /// to all rows filtered by the query, but only one row (the aggregate) will actually be returned.
    ///
    /// The most common use of aggregates is to get the count of columns.
    ///
    ///     let count = User.query(on: ...).count()
    ///
    /// They can also be used to generate sums or averages for all values in a column.
    associatedtype QueryAggregate

    /// Counts the number of matching entities.
    static var queryAggregateCount: QueryAggregate { get }

    /// Adds all values of the chosen field.
    static var queryAggregateSum: QueryAggregate { get }

    /// Averges all values of the chosen field.
    static var queryAggregateAverage: QueryAggregate { get }

    /// Returns the minimum value for the chosen field.
    static var queryAggregateMinimum: QueryAggregate { get }

    /// Returns the maximum value for the chosen field.
    static var queryAggregateMaximum: QueryAggregate { get }

    // MARK: Data

    /// Type input into this query when creating or updating data.
    /// Encoded by `queryEncode(...)` method on `QuerySupporting`.
    associatedtype QueryData

    static func queryDataApply(_ data: QueryData, to query: inout Query)

    // MARK: Field

    associatedtype QueryField

    static func queryField(_ property: FluentProperty) -> QueryField

    // MARK: Filter

    /// Associated filter method. i.e., equals, not equals, greater than, etc.
    associatedtype QueryFilterMethod

    /// ==
    static var queryFilterMethodEqual: QueryFilterMethod { get }

    /// !=
    static var queryFilterMethodNotEqual: QueryFilterMethod { get }

    /// >
    static var queryFilterMethodGreaterThan: QueryFilterMethod { get }

    /// <
    static var queryFilterMethodLessThan: QueryFilterMethod { get }

    /// >=
    static var queryFilterMethodGreaterThanOrEqual: QueryFilterMethod { get }

    /// <=
    static var queryFilterMethodLessThanOrEqual: QueryFilterMethod { get }

    /// ~=
    static var queryFilterMethodInSubset: QueryFilterMethod { get }

    /// !~=
    static var queryFilterMethodNotInSubset: QueryFilterMethod { get }

    /// Associated filter value. Usually the number of binds for this filter alongside special nil cases.
    associatedtype QueryFilterValue

    /// One or more bound values.
    static func queryFilterValue(_ encodables: [Encodable]) -> QueryFilterValue

    /// Indicates a `nil` filter value.
    static var queryFilterValueNil: QueryFilterValue { get }

    /// Nestable query filter type.
    associatedtype QueryFilter

    /// Creates an instance of self from a field method and value.
    ///
    /// - parameters:
    ///     - field: Field to filter.
    ///     - method: Method to compare field and value.
    ///     - value: Value type.
    static func queryFilter(_ field: QueryField, _ method: QueryFilterMethod, _ value: QueryFilterValue) -> QueryFilter

    static func queryFilters(for query: Query) -> [QueryFilter]

    static func queryFilterApply(_ filter: QueryFilter, to query: inout Query)

    /// Associated filter group relation type. Describes how filters can be related.
    associatedtype QueryFilterRelation

    /// &&
    static var queryFilterRelationAnd: QueryFilterRelation { get }

    /// ||
    static var queryFilterRelationOr: QueryFilterRelation { get }

    /// Creates an instance of self from a relation and an array of other filters.
    ///
    /// - parameters:
    ///     - relation: How to relate the grouped filters.
    ///     - filters: An array of filters to group.
    static func queryFilterGroup(_ relation: QueryFilterRelation, _ filters: [QueryFilter]) -> QueryFilter

    // MARK: Key

    /// Represents a field to fetch from the database during a query.
    /// This can be regular fields, computed fields (such as aggregates), or special values like "all fields".
    associatedtype QueryKey

    /// Special "all fields" query key.
    static var queryKeyAll: QueryKey { get }

    /// Creates an aggregate-type (computed) query key.
    ///
    /// - parameters:
    ///     - method: Aggregate method to use.
    ///     - field: Keys to aggregate. Can be zero.
    static func queryAggregate(_ aggregate: QueryAggregate, _ fields: [QueryKey]) -> QueryKey

    static func queryKey(_ field: QueryField) -> QueryKey

    static func queryKeyApply(_ key: QueryKey, to query: inout Query)

    // MARK: Range

    /// Creates a new `QueryRange` with a count and offset.
    ///
    /// - parameters:
    ///     - lower: Amount to offset the query by.
    ///     - upper: `upper` - `lower` = maximum results.
    static func queryRangeApply(lower: Int, upper: Int?, to query: inout Query)

    // MARK: Sort

    associatedtype QuerySort
    associatedtype QuerySortDirection
    static func querySort(_ field: QueryField, _ direction: QuerySortDirection) -> QuerySort
    static var querySortDirectionAscending: QuerySortDirection { get }
    static var querySortDirectionDescending: QuerySortDirection { get }
    static func querySortApply(_ sort: QuerySort, to query: inout Query)
}
