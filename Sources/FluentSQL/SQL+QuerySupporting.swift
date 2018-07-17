extension QuerySupporting where Query: FluentSQLQuery {
    /// See `QuerySupporting`.
    public static func query(_ entity: String) -> Query {
        return .query(.select, .table(.identifier(entity)))
    }
    
    /// See `QuerySupporting`.
    public static func queryEntity(for query: Query) -> String {
        return query.table.identifier.string
    }
}

extension QuerySupporting where QueryAction: FluentSQLQueryStatement {
    /// See `QuerySupporting`.
    public static var queryActionCreate: QueryAction {
        return .insert
    }
    
    /// See `QuerySupporting`.
    public static var queryActionRead: QueryAction {
        return .select
    }
    
    /// See `QuerySupporting`.
    public static var queryActionUpdate: QueryAction {
        return .update
    }
    
    /// See `QuerySupporting`.
    public static var queryActionDelete: QueryAction {
        return .delete
    }
    
    /// See `QuerySupporting`.
    public static func queryActionIsCreate(_ action: QueryAction) -> Bool {
        return action.isInsert
    }
}

extension QuerySupporting where QueryFilterMethod: SQLBinaryOperator {
    /// See `QuerySupporting`.
    public static var queryFilterMethodEqual: QueryFilterMethod {
        return .equal
    }
    
    /// See `QuerySupporting`.
    public static var queryFilterMethodNotEqual: QueryFilterMethod {
        return .notEqual
    }
    
    /// See `QuerySupporting`.
    public static var queryFilterMethodGreaterThan: QueryFilterMethod {
        return .greaterThan
    }
    
    /// See `QuerySupporting`.
    public static var queryFilterMethodLessThan: QueryFilterMethod {
        return .lessThan
    }
    
    /// See `QuerySupporting`.
    public static var queryFilterMethodGreaterThanOrEqual: QueryFilterMethod {
        return .greaterThanOrEqual
    }
    
    /// See `QuerySupporting`.
    public static var queryFilterMethodLessThanOrEqual: QueryFilterMethod {
        return .lessThanOrEqual
    }
    
    /// See `QuerySupporting`.
    public static var queryFilterMethodInSubset: QueryFilterMethod {
        return .in
    }
    
    /// See `QuerySupporting`.
    public static var queryFilterMethodNotInSubset: QueryFilterMethod {
        return .notIn
    }
}

extension QuerySupporting where QueryFilterRelation: SQLBinaryOperator {
    /// See `QuerySupporting`.
    public static var queryFilterRelationAnd: QueryFilterRelation {
        return .and
    }
    
    /// See `QuerySupporting`.
    public static var queryFilterRelationOr: QueryFilterRelation {
        return .or
    }
}

// MARK: QuerySort

extension QuerySupporting where QuerySortDirection: SQLDirection {
    /// See `QuerySupporting`.
    public static var querySortDirectionAscending: QuerySortDirection {
        return .ascending
    }
    
    /// See `QuerySupporting`.
    public static var querySortDirectionDescending: QuerySortDirection {
        return .descending
    }
}

extension QuerySupporting where
    QuerySort: SQLOrderBy,
    QuerySortDirection == QuerySort.Direction,
    QueryField == QuerySort.Expression.ColumnIdentifier
{
    /// See `QuerySupporting`.
    public static func querySort(_ column: QueryField, _ direction: QuerySortDirection) -> QuerySort {
        return .orderBy(.column(column), direction)
    }
}

extension QuerySupporting where Query: FluentSQLQuery, QuerySort == Query.OrderBy {
    /// See `QuerySupporting`.
    public static func querySortApply(_ orderBy: QuerySort, to query: inout Query) {
        query.orderBy.append(orderBy)
    }
}

// MARK: Aggregate

extension QuerySupporting where QueryAggregate == String, Query: FluentSQLQuery {
    /// See `QuerySupporting`.
    public static var queryAggregateCount: QueryAggregate {
        return "COUNT"
    }
    
    /// See `QuerySupporting`.
    public static var queryAggregateSum: QueryAggregate {
        return "SUM"
    }
    
    /// See `QuerySupporting`.
    public static var queryAggregateAverage: QueryAggregate {
        return "AVG"
    }
    
    /// See `QuerySupporting`.
    public static var queryAggregateMinimum: QueryAggregate {
        return "MIN"
    }
    
    /// See `QuerySupporting`.
    public static var queryAggregateMaximum: QueryAggregate {
        return "MAX"
    }
}

extension QuerySupporting where
    QueryAggregate == String,
    QueryKey: SQLSelectExpression,
    QueryKey.Expression == QueryKey.Expression.Function.Argument.Expression
{
    /// See `QuerySupporting`.
    public static func queryAggregate(_ name: QueryAggregate, _ fields: [QueryKey]) -> QueryKey {
        let args: [QueryKey.Expression.Function.Argument] = fields.compactMap { expr in
            if expr.isAll {
                return .all
            } else if let (expr, _) = expr.expression {
                return .expression(expr)
            } else {
                return nil
            }
        }
        return .expression(.function(.function(name, args)), alias: .identifier("fluentAggregate"))
    }
    
}

// MARK: QueryRange

extension QuerySupporting where Query: FluentSQLQuery {
    /// See `QuerySupporting`.
    public static func queryRangeApply(lower: Int, upper: Int?, to query: inout Query) {
        if let upper = upper {
            query.limit = upper - lower
            query.offset = lower
        } else {
            query.offset = lower
        }
    }
}

// MARK: QueryKey

extension QuerySupporting where QueryKey: SQLSelectExpression {
    /// See `QuerySupporting`.
    public static var queryKeyAll: QueryKey {
        return .all
    }
}

extension QuerySupporting where QueryKey: SQLSelectExpression, QueryField == QueryKey.Expression.ColumnIdentifier {
    /// See `QuerySupporting`.
    public static func queryKey(_ field: QueryField) -> QueryKey {
        return .expression(.column(field), alias: nil)
    }
}

extension QuerySupporting where Query: FluentSQLQuery, QueryKey == Query.SelectExpression {
    /// See `QuerySupporting`.
    public static func queryKeyApply(_ key: QueryKey, to query: inout Query) {
        query.keys.append(key)
    }
}

// MARK: QueryFilter

extension QuerySupporting where
    QueryFilter: SQLExpression,
    QueryField == QueryFilter.ColumnIdentifier,
    QueryFilterMethod == QueryFilter.BinaryOperator,
    QueryFilterValue == QueryFilter
{
    /// See `QuerySupporting`.
    public static func queryFilter(_ field: QueryField, _ method: QueryFilterMethod, _ value: QueryFilterValue) -> QueryFilter {
        return .binary(.column(field), method, value)
    }
}

extension QuerySupporting where Query: FluentSQLQuery, QueryFilter == Query.Expression {
    /// See `QuerySupporting`.
    public static func queryFilters(for query: Query) -> [QueryFilter] {
        switch query.predicate {
        case .none: return []
        case .some(let wrapped): return [wrapped]
        }
    }
}

extension QuerySupporting where Query: FluentSQLQuery, QueryFilter == Query.Expression, QueryFilter.BinaryOperator: Equatable {
    /// See `QuerySupporting`.
    public static func queryFilterApply(_ filter: QueryFilter, to query: inout Query) {
        switch query.defaultBinaryOperator {
        case .or: query.predicate |= filter
        default: query.predicate &= filter
        }
    }
}

extension QuerySupporting where Query: FluentSQLQuery, QueryFilterRelation == Query.Expression.BinaryOperator {
    /// See `QuerySupporting`.
    public static func queryDefaultFilterRelation(_ relation: QueryFilterRelation, on query: inout Query) {
        query.defaultBinaryOperator = relation
    }
}

extension QuerySupporting where Query: FluentSQLQuery, QueryAction == Query.Statement {
    /// See `QuerySupporting`.
    public static func queryActionApply(_ action: QueryAction, to query: inout Query) {
        query.statement = action
    }
}


extension QuerySupporting where Query: FluentSQLQuery, QueryField: SQLColumnIdentifier {
    /// See `QuerySupporting`.
    public static func queryDataSet<E>(_ field: QueryField, to data: E, on query: inout Query)
        where E: Encodable
    {
        query.values[field.identifier.string] = .bind(.encodable(data))
    }
}

extension QuerySupporting where Query: FluentSQLQuery, QueryData == Dictionary<String, Query.Expression> {
    /// See `QuerySupporting`.
    public static func queryDataApply(_ data: QueryData, to query: inout Query) {
        query.values = data
    }
}

extension QuerySupporting where QueryField: SQLColumnIdentifier {
    /// See `QuerySupporting`.
    public static func queryField(_ property: FluentProperty) -> QueryField {
        return .column(property.entity.flatMap { .table(.identifier($0)) }, .identifier(property.path[0]))
    }
}

extension QuerySupporting where QueryFilterValue: SQLExpression {
    /// See `QuerySupporting`.
    public static var queryFilterValueNil: QueryFilterValue {
        return .literal(.null)
    }
}

extension QuerySupporting where QueryFilterValue: SQLExpression {
    /// See `QuerySupporting`.
    public static func queryFilterValue<E>(_ encodables: [E]) -> QueryFilterValue
        where E: Encodable
    {
        return .group(encodables.map { .bind(.encodable($0)) })
    }
}

extension QuerySupporting where Query: FluentSQLQuery, QueryData == Dictionary<String, Query.Expression> {
    /// See `QuerySupporting`.
    public static func queryEncode<E>(_ value: E, entity: String) throws -> QueryData where E : Encodable {
        return SQLQueryEncoder(Query.Expression.self).encode(value)
    }
}

extension QuerySupporting where QueryFilter: SQLExpression, QueryFilterRelation == QueryFilter.BinaryOperator, QueryFilter.BinaryOperator: Equatable {
    /// See `QuerySupporting`.
    public static func queryFilterGroup(_ relation: QueryFilterRelation, _ filters: [QueryFilter]) -> QueryFilter {
        var current: QueryFilter?
        for next in filters {
            switch relation {
            case .or: current |= next
            case .and: current &= next
            default: break
            }
        }
        if let predicate = current {
            return .group([predicate])
        } else {
            return .group([])
        }
    }
}

extension QuerySupporting where Query: FluentSQLQuery, Connection: SQLConnection, Output == Connection.Output {
    /// See `QuerySupporting`.
    public static func queryDecode<D>(_ output: Output, entity: String, as decodable: D.Type, on conn: Connection) -> Future<D> where D : Decodable {
        do {
            let row = try conn.decode(D.self, from: output, table: .table(.identifier(entity)))
            return conn.future(row)
        } catch {
            return conn.future(error: error)
        }
    }
}
