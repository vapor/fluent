/// SQL database.
public protocol SQLSupporting: QuerySupporting & JoinSupporting & MigrationSupporting where
    Query == DataManipulationQuery,
    QueryAction == DataManipulationStatement,
    QueryAggregate == String,
    QueryData == [DataManipulationColumn],
    QueryField == DataColumn,
    QueryFilterMethod == DataPredicateComparison,
    QueryFilterValue == DataManipulationValue,
    QueryFilter == DataPredicates,
    QueryFilterRelation == DataPredicateGroupRelation,
    QueryKey == DataManipulationKey,
    QuerySort == DataOrderBy,
    QuerySortDirection == DataOrderByDirection
{
    static func schemaDataType(for type: Any.Type, primaryKey: Bool) -> DataDefinitionDataType

    /// Executes the supplied schema on the database connection.
    static func schemaExecute(_ ddl: DataDefinitionQuery, on connection: Connection) -> Future<Void>

    /// Enables references errors.
    static func enableReferences(on conn: Connection) -> Future<Void>

    /// Disables reference errors.
    static func disableReferences(on conn: Connection) -> Future<Void>
}

extension SQLSupporting {
    // MARK: Action

    public static var queryActionCreate: DataManipulationStatement {
        return .insert()
    }

    public static var queryActionRead: DataManipulationStatement {
        return .select()
    }

    public static var queryActionUpdate: DataManipulationStatement {
        return .update()
    }

    public static var queryActionDelete: DataManipulationStatement {
        return .delete()
    }

    public static func queryActionIsCreate(_ statement: DataManipulationStatement) -> Bool {
        switch statement.verb {
        case "INSERT": return true
        default: return false
        }
    }

    public static func queryActionApply(_ statement: DataManipulationStatement, to query: inout DataManipulationQuery) {
        query.statement = statement
    }

    // MARK: Aggregate

    public static var queryAggregateCount: QueryAggregate {
        return "COUNT"
    }

    public static var queryAggregateSum: QueryAggregate {
        return "SUM"
    }

    public static var queryAggregateAverage: QueryAggregate {
        return "AVERAGE"
    }

    public static var queryAggregateMinimum: QueryAggregate {
        return "MIN"
    }

    public static var queryAggregateMaximum: QueryAggregate {
        return "MAX"
    }

    public static func queryAggregate(_ function: String, _ keys: [DataManipulationKey]) -> DataManipulationKey {
        return .computed(.init(function: function, keys: keys), key: "fluentAggregate")
    }

    public static func query(_ entity: String) -> DataManipulationQuery {
        return .init(table: entity)
    }

    // MARK: Data

    public static func queryDataApply(_ columns: [DataManipulationColumn], to query: inout DataManipulationQuery) {
        query.columns = columns
    }

    public static func queryDataSet(_ field: DataColumn, to data: Encodable, on query: inout DataManipulationQuery) {
        query.columns.append(.init(column: field, value: .bind(data)))
    }

    // MARK: Field

    public static func queryField(_ property: FluentProperty) -> DataColumn {
        return .fluentProperty(property)
    }

    // MARK: Filter

    public static var queryFilterMethodEqual: DataPredicateComparison {
        return .equal
    }

    public static var queryFilterMethodNotEqual: DataPredicateComparison {
        return .notEqual
    }

    public static var queryFilterMethodGreaterThan: DataPredicateComparison {
        return .greaterThan
    }

    public static var queryFilterMethodLessThan: DataPredicateComparison {
        return .lessThan
    }

    public static var queryFilterMethodGreaterThanOrEqual: DataPredicateComparison {
        return .greaterThanOrEqual
    }

    public static var queryFilterMethodLessThanOrEqual: DataPredicateComparison {
        return .lessThanOrEqual
    }

    public static var queryFilterMethodInSubset: DataPredicateComparison {
        return .in
    }

    public static var queryFilterMethodNotInSubset: DataPredicateComparison {
        return .notIn
    }

    public static func queryFilterValue(_ encodables: [Encodable]) -> DataManipulationValue {
        return .binds(encodables)
    }

    public static var queryFilterValueNil: QueryFilterValue {
        return .null
    }

    public static func queryFilters(for query: Query) -> [DataPredicates] {
        return query.predicates
    }

    public static func queryFilterApply(_ filter: QueryFilter, to query: inout Query) {
        query.predicates.append(filter)
    }

    public static func queryFilter(_ column: DataColumn, _ comparison: QueryFilterMethod, _ value: DataManipulationValue) -> DataPredicates {
        return .predicate(.init(column: column, comparison: comparison, value: value))
    }

    public static var queryFilterRelationAnd: DataPredicateGroupRelation {
        return .and
    }

    public static var queryFilterRelationOr: DataPredicateGroupRelation {
        return .or
    }

    public static func queryFilterGroup(_ relation: QueryFilterRelation, _ predicates: [QueryFilter]) -> DataPredicates {
        return .group(.init(relation: relation, predicates: predicates))
    }

    // MARK: Join

    public static var queryJoinMethodDefault: DataJoinMethod {
        return .inner
    }

    public static func queryJoin(_ method: DataJoinMethod, base: DataColumn, joined: DataColumn) -> DataJoin {
        return .init(method: method, local: base, foreign: joined)
    }

    public static func queryJoinApply(_ join: DataJoin, to query: inout DataManipulationQuery) {
        query.joins.append(join)
    }

    // MARK: Key

    public static var queryKeyAll: DataManipulationKey {
        return .all(table: nil)
    }

    public static func queryKey(_ column: DataColumn) -> DataManipulationKey {
        return .column(column, key: nil)
    }

    public static func queryKeyApply(_ key: DataManipulationKey, to query: inout DataManipulationQuery) {
        query.keys.append(key)
    }

    // MARK: Range

    public static func queryRangeApply(lower: Int, upper: Int?, to query: inout DataManipulationQuery) {
        query.offset = lower
        if let upper = upper {
            query.limit = upper - lower
        }
    }

    // MARK: Sort

    public static func querySort(_ column: DataColumn, _ direction: DataOrderByDirection) -> DataOrderBy {
        return .init(columns: [column], direction: direction)
    }

    public static var querySortDirectionAscending: QuerySortDirection {
        return .ascending
    }

    public static var querySortDirectionDescending: QuerySortDirection {
        return .descending
    }

    public static func querySortApply(_ orderBy: DataOrderBy, to query: inout DataManipulationQuery) {
        query.orderBys.append(orderBy)
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
        return schemaExecute(.init(statement: .drop, table: Model.entity), on: conn)
    }
}

extension SchemaBuilder {
    public func customSQL(_ closure: (inout DataDefinitionQuery) -> ()) -> Self {
        closure(&schema)
        return self
    }
}

extension QueryBuilder where Model.Database: SQLSupporting {
    public func customSQL(_ closure: (inout Model.Database.Query) -> ()) -> Self {
        closure(&query)
        return self
    }
}

extension DataColumn {
    public static func fluentProperty(_ property: FluentProperty) -> DataColumn {
        guard let model = property.rootType as? AnyModel.Type else {
            fatalError("`\(property.rootType)` does not conform to `Model`.")
        }
        return .init(table: model.entity, name: property.path.first ?? "")
    }
}
