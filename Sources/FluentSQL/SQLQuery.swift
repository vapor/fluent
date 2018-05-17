public enum SQLValue: QueryData {
    public static func fluentEncodable(_ encodable: Encodable) -> SQLValue {
        return .encodable(encodable)
    }

    case encodable(Encodable)
}

public struct SQLQuery: Query, JoinsContaining {
    public var table: String
    public var statement: SQLStatement
    public var binds: [SQLValue]
    public var data: [DataColumn: SQLValue]
    public var columns: [DataQueryColumn]
    public var joins: [DataJoin]
    public var limit: Int?
    public var offset: Int?
    public var orderBys: [DataOrderBy]
    public var predicates: [DataPredicateItem]

    public init(table: String) {
        self.table = table
        self.binds = []
        self.columns = []
        self.data = [:]
        self.joins = []
        self.orderBys = []
        self.predicates = []
        self.statement = .data
    }

    public static func fluentQuery(_ table: String) -> SQLQuery {
        return .init(table: table)
    }

    public var fluentAction: SQLStatement {
        get { return statement }
        set { statement = newValue }
    }

    public var fluentBinds: [SQLValue] {
        get { return binds }
        set { binds = newValue }
    }

    public var fluentData: [DataColumn: SQLValue] {
        get { return data }
        set { data = newValue }
    }

    public var fluentFilters: [DataPredicateItem] {
        get { return predicates }
        set { predicates = newValue }
    }

    public var fluentKeys: [DataQueryColumn] {
        get { return columns }
        set { columns = newValue }
    }

    public var fluentJoins: [Join] {
        get { return joins }
        set { joins = newValue }
    }

    public var fluentRanges: [DataLimitOffset] {
        get {
            switch (limit, offset) {
            case (.some(let limit), .some(let offset)):
                let limit = DataLimitOffset(offset: offset, limit: limit)
                return [limit]
            case (.none, .some(let offset)):
                let limit = DataLimitOffset(offset: offset, limit: nil)
                return [limit]
            default: return []
            }
        }
        set {
            if let first = newValue.first {
                limit = first.limit
                offset = first.offset
            } else {
                limit = nil
                offset = nil
            }
        }
    }

    public var fluentSorts: [DataOrderBy] {
        get { return orderBys }
        set { orderBys = newValue }
    }

    public func convertToDataOrManipulationQuery() -> DataOrManipulationQuery {
        switch statement {
        case .data:
            return .data(.init(
                table: table,
                columns: columns.isEmpty ? [.all] : columns,
                joins: joins,
                predicates: predicates,
                orderBys: orderBys,
                groupBys: [] /* FIXME */,
                limit: limit,
                offset: offset
            ))
        case .manipulation(let statement):
            return .manipulation(.init(
                statement: statement,
                table: table,
                columns: data.keys.map { .init(column: $0) },
                joins: joins,
                predicates: predicates,
                limit: limit
            ))
        }
    }

    public typealias Action = SQLStatement
    public typealias Field = DataColumn
    public typealias Filter = DataPredicateItem
    public typealias Data = SQLValue
    public typealias Join = DataJoin
    public typealias Key = DataQueryColumn
    public typealias Range = DataLimitOffset
    public typealias Sort = DataOrderBy
}

extension DataJoin: QueryJoin {
    public static func fluentJoin(_ method: DataJoinMethod, base: DataColumn, joined: DataColumn) -> DataJoin {
        return .init(method: method, local: base, foreign: joined)
    }

    public typealias Field = DataColumn
    public typealias Method = DataJoinMethod
}

extension DataJoinMethod: QueryJoinMethod {
    public static var `default`: DataJoinMethod {
        return .inner
    }
}

public enum DataOrManipulationQuery {
    case data(DataQuery)
    case manipulation(DataManipulationQuery)
}

extension SQLStatement: QueryAction {
    public var fluentIsCreate: Bool {
        switch self {
        case .data: return false
        case .manipulation(let m):
            switch m {
            case .delete, .update: return false
            case .insert: return true
            }
        }
    }

    public static var fluentCreate: SQLStatement {
        return .manipulation(.insert)
    }

    public static var fluentRead: SQLStatement {
        return .data
    }

    public static var fluentUpdate: SQLStatement {
        return .manipulation(.update)
    }

    public static var fluentDelete: SQLStatement {
        return .manipulation(.delete)
    }
}

extension DataPredicateItem: QueryFilter {
    public typealias Field = DataColumn
    public typealias Method = DataPredicateComparison
    public typealias Value = DataPredicateValue
    public typealias Relation = DataPredicateGroupRelation
    public static func unit(_ field: DataColumn, _ method: DataPredicateComparison, _ value: DataPredicateValue) -> DataPredicateItem {
        return .predicate(.init(column: field, comparison: method, value: value))
    }

    public static func group(_ relation: DataPredicateGroupRelation, _ filters: [DataPredicateItem]) -> DataPredicateItem {
        return .group(.init(relation: relation, predicates: filters))
    }

    public func convertToDataPredicateItem() -> DataPredicateItem {
        return self
    }
}

extension DataPredicateComparison: QueryFilterMethod {
    public static var fluentEqual: DataPredicateComparison { return .equal }
    public static var fluentNotEqual: DataPredicateComparison { return .notEqual }
    public static var fluentGreaterThan: DataPredicateComparison { return .greaterThan }
    public static var fluentLessThan: DataPredicateComparison { return .lessThan }
    public static var fluentGreaterThanOrEqual: DataPredicateComparison { return .greaterThanOrEqual}
    public static var fluentLessThanOrEqual: DataPredicateComparison { return .lessThanOrEqual }
    public static var fluentInSubset: DataPredicateComparison { return .in }
    public static var fluentNotInSubset: DataPredicateComparison { return .notIn }
}

extension DataPredicateValue: QueryFilterValue {
    public static func fluentBind(_ count: Int) -> DataPredicateValue {
        return .placeholders(count: count)
    }

    public static var fluentNil: DataPredicateValue {
        return .null
    }

    public static func fluentProperty(_ property: FluentProperty) -> DataPredicateValue {
        return .column(.fluentProperty(property))
    }
}

extension DataPredicateGroupRelation: QueryFilterRelation {
    public static var fluentAnd: DataPredicateGroupRelation { return .and }
    public static var fluentOr: DataPredicateGroupRelation { return .or }
}


extension DataOrderBy: QuerySort {
    public static func unit(_ field: DataColumn, _ direction: DataOrderByDirection) -> DataOrderBy {
        return .init(columns: [field], direction: direction)
    }

    public typealias Field = DataColumn
    public typealias Direction = DataOrderByDirection

    public func convertToDataOrderBy() -> DataOrderBy {
        return self
    }
}

extension DataOrderByDirection: QuerySortDirection {
    public static var fluentAscending: DataOrderByDirection {
        return .ascending
    }

    public static var fluentDescending: DataOrderByDirection {
        return .descending
    }
}

public struct DataLimitOffset: QueryRange {
    public static func fluentRange(lower: Int, upper: Int?) -> DataLimitOffset {
        if let upper = upper {
            return .init(offset: lower, limit: upper - lower)
        } else {
            return .init(offset: lower, limit: nil)
        }

    }

    public var offset: Int
    public var limit: Int?
}

public enum SQLStatement {
    case data
    case manipulation(DataManipulationStatement)
    public func convertToSQLStatement() -> SQLStatement {
        return self
    }

    public static var insert: SQLStatement { return .manipulation(.insert) }
    public static var select: SQLStatement { return .data }
    public static var update: SQLStatement { return .manipulation(.update) }
    public static var delete: SQLStatement { return .manipulation(.delete) }

}

extension SQLSerializer {
    public func serialize(_ query: SQLQuery) -> String {
        switch query.convertToDataOrManipulationQuery() {
        case .manipulation(let m): return serialize(query: m)
        case .data(let q): return serialize(query: q)
        }
    }
}
