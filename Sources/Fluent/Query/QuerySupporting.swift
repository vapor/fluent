/// Capable of executing a database queries as defined by `Query`.
public protocol QuerySupporting: Database {
    /// Associated `Query` type. Instances of this type will be supplied to `queryExecute(...)`.
    associatedtype Query

    /// Creates a new instance of `Query` using the supplied entity `String`. The resulting
    /// query will be stored on the `QueryBuilder` and modified via the other methods on this protocol
    ///
    /// - parameters:
    ///     - entity: Table / collection name to query.
    static func query(_ entity: String) -> Query
    
    /// Returns the entity for the supplied query. Fluent will use this method to help filter decode
    /// results and to create copies of the query builder.
    ///
    /// - parameters:
    ///     - query: Query to return entity for.
    static func queryEntity(for query: Query) -> String

    /// Type returned by this query when reading data. Result set type.
    /// Decoded by `queryDecode(...)` method on `QuerySupporting`.
    associatedtype Output
    
    /// Executes the supplied query on the database connection. Results should be streamed into the handler.
    /// When the query is finished, the returned future should be completed.
    ///
    /// - parameters:
    ///     - query: Query to execute.
    ///     - conn: Database connection to use.
    ///     - handler: Handles query output.
    /// - returns: A future that will complete when the query has finished.
    static func queryExecute(_ query: Query, on conn: Connection, into handler: @escaping (Output, Connection) throws -> ()) -> Future<Void>

    /// Decodes a decodable type `D` from this database's output. This method will be used by Fluent to
    /// convert database output into usable types as determined by the `QueryBuilder` result transformation pipeline.
    ///
    /// - parameters:
    ///     - output: Query output to decode.
    ///     - entity: Entity to decode from (table or collection name).
    ///     - decodable: Decodable type to create.
    ///     - connection: Connection to use for decoding the output.
    /// - returns: Decoded type.
    static func queryDecode<D>(_ output: Output, entity: String, as decodable: D.Type, on conn: Connection) -> Future<D>
        where D: Decodable

    /// Encodes an encodable object into this database's input. This will be used by Fluent to encode types
    /// supplied by the user into an appropriate format for storing on the Query. See `queryDataApply(...)`.
    ///
    /// - parameters:
    ///     - encodable: Item to encode.
    ///     - entity: Entity to encode to (table or collection name).
    /// - returns: Encoded query input.
    static func queryEncode<E>(_ encodable: E, entity: String) throws -> QueryData
        where E: Encodable

    /// This method will be called by Fluent during `Model` lifecycle events.
    /// This gives the database a chance to interact with the model before Fluent encodes it.
    ///
    /// - parameters:
    ///     - event: Specific `ModelEvent` taking place.
    ///     - model: The instance of `Model` that is undergoing the event.
    ///     - conn: Database connection to use.
    /// - returns: A potentially updated copy of the `Model`.
    static func modelEvent<M>(event: ModelEvent, model: M, on conn: Connection) -> Future<M>
        where M: Model, M.Database == Self

    // MARK: Action

    /// Specific query type, usually create, read, update, delete.
    associatedtype QueryAction

    /// Appropriate `QueryAction` for creating data.
    static var queryActionCreate: QueryAction { get }

    /// Appropriate `QueryAction` for reading data.
    static var queryActionRead: QueryAction { get }
    
    /// Appropriate `QueryAction` for updating data.
    static var queryActionUpdate: QueryAction { get }
    
    /// Appropriate `QueryAction` for deleting data.
    static var queryActionDelete: QueryAction { get }
    
    /// Returns `true` if the supplied `QueryAction` is for creating data.
    ///
    /// - parameters:
    ///     - action: `QueryAction` in question.
    static func queryActionIsCreate(_ action: QueryAction) -> Bool
    
    /// Applies a new `QueryAction` to the supplied, mutable query.
    ///
    /// - parameters:
    ///     - action: New `QueryAction` to set on the query.
    ///     - query: Mutable `Query` to update with the new query action.
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

    /// Sets a singular field / value pair on the supplied query.
    ///
    /// - parameters:
    ///     - field: Field in the data to update.
    ///     - data: New encodable data to set.
    ///     - query: Mutable query to set the new data to.
    static func queryDataSet<E>(_ field: QueryField, to data: E, on query: inout Query)
        where E: Encodable

    /// Updates the query's input data to the supplied value.
    ///
    /// - parameters:
    ///     - data: New input data to set on the query.
    ///     - query: Mutable query to update with the new input data.
    static func queryDataApply(_ data: QueryData, to query: inout Query)

    // MARK: Field

    /// Associated query field type. Query fields represent a single property on a model.
    associatedtype QueryField

    /// Creates an instance of `QueryField` from a `FluentProperty`.
    ///
    /// - paramters:
    ///     - property: `FluentProperty` struct to use.
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
    ///
    /// - parameters:
    ///     - encodables: Array of `Encodable` items to convert to filter bind values.
    static func queryFilterValue<E>(_ encodables: [E]) -> QueryFilterValue
        where E: Encodable

    /// Indicates a `nil` filter value.
    static var queryFilterValueNil: QueryFilterValue { get }

    /// Nestable query filter type.
    associatedtype QueryFilter

    /// Creates an instance of `QueryFilter` from a field method and value.
    ///
    /// - parameters:
    ///     - field: Field to filter.
    ///     - method: Method to compare field and value.
    ///     - value: Value type.
    static func queryFilter(_ field: QueryField, _ method: QueryFilterMethod, _ value: QueryFilterValue) -> QueryFilter

    /// Returns all of the query's filters.
    ///
    /// - parameters:
    ///     - query: Query to return filters for.
    static func queryFilters(for query: Query) -> [QueryFilter]

    /// Applies an instance of `QueryFilter` to the mutable query.
    ///
    /// - parameters:
    ///     - filter: New filter to apply.
    ///     - query: Mutable query to apply the new filter to.
    static func queryFilterApply(_ filter: QueryFilter, to query: inout Query)

    /// Associated filter group relation type. Describes how filters can be related.
    associatedtype QueryFilterRelation

    /// &&
    static var queryFilterRelationAnd: QueryFilterRelation { get }

    /// ||
    static var queryFilterRelationOr: QueryFilterRelation { get }
    
    static func queryDefaultFilterRelation(_ relation: QueryFilterRelation, on: inout Query)

    /// Creates an instance of `QueryFilter` from a relation and an array of other filters.
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

    /// Creates a new `QueryKey` from an existing `QueryField`.
    ///
    /// - parameters:
    ///     - field: `QueryField` to use for creating the `QueryKey`.
    /// - returns: Newly created `QueryKey`.
    static func queryKey(_ field: QueryField) -> QueryKey

    /// Applies a new `QueryKey` to the mutable `Query`.
    ///
    /// - parameters:
    ///     - key: New `QueryKey` to apply.
    ///     - query: Mutable `Query` to apply the new `QueryKey` to.
    static func queryKeyApply(_ key: QueryKey, to query: inout Query)

    // MARK: Range

    /// Creates a new `QueryRange` with a count and offset.
    ///
    /// - parameters:
    ///     - lower: Amount to offset the query by.
    ///     - upper: `upper` - `lower` = maximum results.
    static func queryRangeApply(lower: Int, upper: Int?, to query: inout Query)

    // MARK: Sort

    /// Associated sort data structure.
    associatedtype QuerySort

    /// Associated sort direction data structure.
    associatedtype QuerySortDirection
    
    /// Creates a new `QuerySort` from a field and direction.
    ///
    /// - parameters:
    ///     - field: `QueryField` to sort.
    ///     - direction: `QuerySortDirection` to sort the field in.
    /// - returns: Newly created `QuerySort` type.
    static func querySort(_ field: QueryField, _ direction: QuerySortDirection) -> QuerySort
    
    /// Represents an ascending sorted `QuerySortDirection`.
    static var querySortDirectionAscending: QuerySortDirection { get }
    
    /// Represents a descending sorted `QuerySortDirection`.
    static var querySortDirectionDescending: QuerySortDirection { get }
    
    /// Applies a new `QuerySort` to the mutable `Query`.
    ///
    /// - parameters:
    ///     - sort: New `QuerySort` to apply.
    ///     - query: Mutable `Query` to apply the sort to.
    static func querySortApply(_ sort: QuerySort, to query: inout Query)
}

