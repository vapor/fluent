/// SQL database.
public protocol SQLSupporting: QuerySupporting & JoinSupporting & MigrationSupporting & TransactionSupporting & KeyedCacheSupporting where
    Query == SQLQuery.DML,
    QueryAction == SQLQuery.DML.Statement,
    QueryAggregate == String,
    QueryData == [SQLQuery.DML.Column: SQLQuery.DML.Value],
    QueryField == SQLQuery.DML.Column,
    QueryFilterMethod == SQLQuery.DML.Predicate.Comparison,
    QueryFilterValue == SQLQuery.DML.Value,
    QueryFilter == SQLQuery.DML.Predicate,
    QueryFilterRelation == SQLQuery.DML.Predicate.Relation,
    QueryKey == SQLQuery.DML.Key,
    QuerySort == SQLQuery.DML.OrderBy,
    QuerySortDirection == SQLQuery.DML.OrderBy.Direction,
    QueryJoin == SQLQuery.DML.Join,
    QueryJoinMethod == SQLQuery.DML.Join.Method
{
    static func schemaColumnType(for type: Any.Type, primaryKey: Bool) -> SQLQuery.DDL.ColumnDefinition.ColumnType

    /// Executes the supplied schema on the database connection.
    static func schemaExecute(_ ddl: SQLQuery.DDL, on conn: Connection) -> Future<Void>

    /// Enables references errors.
    static func enableReferences(on conn: Connection) -> Future<Void>

    /// Disables reference errors.
    static func disableReferences(on conn: Connection) -> Future<Void>
}

extension SQLSupporting {
    // MARK: Action

    /// See `QuerySupporting.`
    public static var queryActionCreate: QueryAction {
        return .insert
    }

    /// See `QuerySupporting.`
    public static var queryActionRead: QueryAction {
        return .select
    }

    /// See `QuerySupporting.`
    public static var queryActionUpdate: QueryAction {
        return .update
    }

    /// See `QuerySupporting.`
    public static var queryActionDelete: QueryAction {
        return .delete
    }

    /// See `QuerySupporting.`
    public static func queryActionIsCreate(_ statement: QueryAction) -> Bool {
        switch statement.verb {
        case "INSERT": return true
        default: return false
        }
    }

    /// See `QuerySupporting.`
    public static func queryActionApply(_ statement: QueryAction, to query: inout Query) {
        query.statement = statement
    }

    // MARK: Aggregate

    /// See `QuerySupporting.`
    public static var queryAggregateCount: QueryAggregate {
        return "COUNT"
    }

    /// See `QuerySupporting.`
    public static var queryAggregateSum: QueryAggregate {
        return "SUM"
    }

    /// See `QuerySupporting.`
    public static var queryAggregateAverage: QueryAggregate {
        return "AVERAGE"
    }

    /// See `QuerySupporting.`
    public static var queryAggregateMinimum: QueryAggregate {
        return "MIN"
    }

    /// See `QuerySupporting.`
    public static var queryAggregateMaximum: QueryAggregate {
        return "MAX"
    }

    /// See `QuerySupporting.`
    public static func queryAggregate(_ function: String, _ keys: [QueryKey]) -> QueryKey {
        return .computed(.init(function: function, keys: keys), as: "fluentAggregate")
    }

    /// See `QuerySupporting.`
    public static func query(_ entity: String) -> Query {
        return .init(statement: .select, table: entity)
    }
    
    /// See `QuerySupporting.`
    public static func queryEntity(for query: Query) -> String {
        return query.table
    }

    // MARK: Data

    public static func queryDataApply(_ columns: QueryData, to query: inout Query) {
        query.columns = columns
    }

    public static func queryDataSet(_ field: QueryField, to data: Encodable, on query: inout Query) {
        query.columns[field] = .bind(data)
    }

    // MARK: Field

    public static func queryField(_ property: FluentProperty) -> QueryField {
        return .fluentProperty(property)
    }

    // MARK: Filter

    public static var queryFilterMethodEqual: QueryFilterMethod {
        return .equal
    }

    public static var queryFilterMethodNotEqual: QueryFilterMethod {
        return .notEqual
    }

    public static var queryFilterMethodGreaterThan: QueryFilterMethod {
        return .greaterThan
    }

    public static var queryFilterMethodLessThan: QueryFilterMethod {
        return .lessThan
    }

    public static var queryFilterMethodGreaterThanOrEqual: QueryFilterMethod {
        return .greaterThanOrEqual
    }

    public static var queryFilterMethodLessThanOrEqual: QueryFilterMethod {
        return .lessThanOrEqual
    }

    public static var queryFilterMethodInSubset: QueryFilterMethod {
        return .in
    }

    public static var queryFilterMethodNotInSubset: QueryFilterMethod {
        return .notIn
    }

    public static func queryFilterValue(_ encodables: [Encodable]) -> QueryFilterValue {
        return .binds(encodables)
    }

    public static var queryFilterValueNil: QueryFilterValue {
        return .null
    }

    public static func queryFilters(for query: Query) -> [QueryFilter] {
        return query.predicates
    }

    public static func queryFilterApply(_ filter: QueryFilter, to query: inout Query) {
        query.predicates.append(filter)
    }

    public static func queryFilter(_ column: QueryField, _ comparison: QueryFilterMethod, _ value: QueryFilterValue) -> QueryFilter {
        return .predicate(column, comparison, value)
    }

    public static var queryFilterRelationAnd: QueryFilterRelation {
        return .and
    }

    public static var queryFilterRelationOr: QueryFilterRelation {
        return .or
    }

    public static func queryFilterGroup(_ relation: QueryFilterRelation, _ predicates: [QueryFilter]) -> QueryFilter {
        return .group(relation, predicates)
    }

    // MARK: Join

    /// See `SQLSupporting`.
    public static var queryJoinMethodDefault: QueryJoinMethod {
        return .inner
    }

    /// See `SQLSupporting`.
    public static func queryJoin(_ method: QueryJoinMethod, base: QueryField, joined: QueryField) -> QueryJoin {
        return .init(method: method, local: base, foreign: joined)
    }

    /// See `SQLSupporting`.
    public static func queryJoinApply(_ join: QueryJoin, to query: inout Query) {
        query.joins.append(join)
    }

    // MARK: Key

    public static var queryKeyAll: QueryKey {
        return .all(table: nil)
    }

    public static func queryKey(_ column: QueryField) -> QueryKey {
        return .column(column)
    }

    public static func queryKeyApply(_ key: QueryKey, to query: inout Query) {
        query.keys.append(key)
    }

    // MARK: Range

    public static func queryRangeApply(lower: Int, upper: Int?, to query: inout Query) {
        query.offset = lower
        if let upper = upper {
            query.limit = upper - lower
        }
    }

    // MARK: Sort

    public static func querySort(_ column: QueryField, _ direction: QuerySortDirection) -> QuerySort {
        return .init(columns: [column], direction: direction)
    }

    public static var querySortDirectionAscending: QuerySortDirection {
        return .ascending
    }

    public static var querySortDirectionDescending: QuerySortDirection {
        return .descending
    }

    public static func querySortApply(_ orderBy: QuerySort, to query: inout Query) {
        query.orderBys.append(orderBy)
    }
    
    // MARK: Encode
    
    /// See `SQLDatabase`.
    public static func queryEncode<E>(_ encodable: E, entity: String) throws -> QueryData where E: Encodable {
        return try SQLRowEncoder<Self>().encode(encodable, tableName: entity)
    }

    // MARK: Convenience

    /// Convenience for creating a closure that accepts a schema creator
    /// for the supplied model type on this schema executor.
    public static func create<Model>(_ model: Model.Type, on conn: Connection, closure: @escaping (SchemaCreator<Model>) throws -> ()) -> Future<Void>
        where Model.Database == Self
    {
        let creator = SchemaCreator(Model.self)
        return Future.flatMap(on: conn) {
            try closure(creator)
            return self.schemaExecute(creator.schema, on: conn)
        }
    }

    /// Convenience for creating a closure that accepts a schema updater
    /// for the supplied model type on this schema executor.
    public static func update<Model>(_ model: Model.Type, on conn: Connection, closure: @escaping (SchemaUpdater<Model>) throws -> ()) -> Future<Void>
        where Model.Database == Self
    {
        let updater = SchemaUpdater(Model.self)
        return Future.flatMap(on: conn) {
            try closure(updater)
            return self.schemaExecute(updater.schema, on: conn)
        }
    }

    /// Convenience for deleting the schema for the supplied model type.
    public static func delete<Model>(_ model: Model.Type, on conn: Connection) -> Future<Void>
        where Model: Fluent.Model, Model.Database == Self
    {
        return schemaExecute(.init(statement: .drop, table: Model.entity, createColumns: [], deleteColumns: [], createConstraints: [], deleteConstraints: []), on: conn)
    }
}

extension SQLQuery.DML.Column {
    public static func fluentProperty(_ property: FluentProperty) -> SQLQuery.DML.Column {
        guard let model = property.rootType as? AnyModel.Type else {
            fatalError("`\(property.rootType)` does not conform to `Model`.")
        }
        return .init(table: model.entity, name: property.path.first ?? "")
    }
}
