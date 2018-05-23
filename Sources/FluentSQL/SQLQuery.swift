
public struct FooDatabase: QuerySupporting {

    public typealias Query = FooQuery
    public typealias Connection = FooConnection


    public static func queryExecute(_ query: FooQuery, on conn: Connection, into handler: @escaping (String, Connection) throws -> ()) -> Future<Void> {
        fatalError()
    }

    public static func queryDecode<D>(_ output: String, entity: String, as decodable: D.Type) throws -> D
        where D: Decodable
    {
        fatalError()
    }

    public static func queryEncode<E>(_ encodable: E, entity: String) throws -> String
        where E: Encodable
    {
        fatalError()
    }

    public static func modelEvent<M>(event: ModelEvent, model: M, on conn: Connection) -> Future<M>
        where FooDatabase == M.Database, M : Model
    {
        fatalError()
    }

    public func newConnection(on worker: Worker) -> Future<FooConnection> {
        fatalError()
    }
}

public final class FooConnection: DatabaseConnection {
    public var isClosed: Bool
    public var extend: Extend

    init() {
        self.isClosed = false
        self.extend = [:]
    }

    public func close() {
        fatalError()
    }


    public func next() -> EventLoop {
        fatalError()
    }

    public func shutdownGracefully(queue: DispatchQueue, _ callback: @escaping (Error?) -> Void) {
        fatalError()
    }
}

public struct FooQuery: SQLQuery {
    public typealias Data = String
    public typealias Input = String
    public typealias Output = String

    public init(table: String) {
        self.table = table
        self.statement = .insert
        self.binds = []
        self.data = ""
        self.predicates = []
        self.columns = []
        self.limit = nil
        self.offset = nil
        self.orderBys = []
        self.groupBys = []
        self.joins = []
    }

    public var table: String
    public var statement: SQLStatement
    public var binds: [String]
    public var data: String
    public var predicates: [DataPredicateItem]
    public var columns: [DataQueryColumn]
    public var limit: Int?
    public var offset: Int?
    public var orderBys: [DataOrderBy]
    public var groupBys: [DataGroupBy]
    public var joins: [DataJoin]
}

extension String: QueryData {
    public static func fluentEncodable(_ encodable: Encodable) -> String {
        fatalError()
    }
}

extension String: DataManipulationColumnsRepresentable {
    public func convertToDataManipulationColumns() -> [DataManipulationColumn] {
        fatalError()
    }
}








public protocol SQLQuery: Query & JoinsContaining where
    Action == SQLStatement,
    Input: DataManipulationColumnsRepresentable,
    Filter == DataPredicateItem,
    Key == DataQueryColumn,
    Range == DataLimitOffset,
    Join == DataJoin,
    Sort == DataOrderBy
{
    init(table: String)

    var table: String { get set }
    var statement: SQLStatement { get set }
    var binds: [Data] { get set }
    var data: Input { get set }
    var predicates: [DataPredicateItem] { get set }
    var columns: [DataQueryColumn] { get set }
    var limit: Int? { get set }
    var offset: Int? { get set }
    var orderBys: [DataOrderBy] { get set }
    var groupBys: [DataGroupBy] { get set }
    var joins: [DataJoin] { get set }
}

extension SQLQuery {
    /// See `Query`.
    public static func fluentQuery(_ table: String) -> Self {
        return .init(table: table)
    }

    /// See `Query.
    public var fluentAction: SQLStatement {
        get { return statement }
        set { statement = newValue}
    }

    /// See `Query.
    public var fluentBinds: [Data] {
        get { return binds }
        set { binds = newValue }
    }

    /// See `Query.
    public var fluentData: Input {
        get { return data }
        set { data = newValue }
    }

    /// See `Query.
    public var fluentFilters: [DataPredicateItem] {
        get { return predicates }
        set { predicates = newValue }
    }

    /// See `Query.
    public var fluentKeys: [DataQueryColumn] {
        get { return columns }
        set { columns = newValue }
    }

    /// See `Query.
    public var fluentRange: DataLimitOffset? {
        get {
            switch (limit, offset) {
            case (.some(let limit), .some(let offset)):
                return .init(offset: offset, limit: limit)
            case (.none, .some(let offset)):
                return .init(offset: offset, limit: nil)
            default: return nil
            }
        }
        set {
            if let first = newValue {
                limit = first.limit
                offset = first.offset
            } else {
                limit = nil
                offset = nil
            }
        }
    }
    /// See `JoinsContaining`.
    public var fluentJoins: [DataJoin] {
        get { return joins }
        set { joins = newValue }
    }

    /// See `Query.
    public var fluentSorts: [DataOrderBy] {
        get { return orderBys }
        set { orderBys = newValue }
    }
}

public protocol DataManipulationColumnsRepresentable {
    func convertToDataManipulationColumns() -> [DataManipulationColumn]
}

extension SQLQuery {
    public func convertToDataOrManipulationQuery() -> DataOrManipulationQuery {
        switch statement {
        case .data:
            return .data(.init(
                table: table,
                columns: columns.isEmpty ? [.all] : columns,
                joins: joins,
                predicates: predicates,
                orderBys: orderBys,
                groupBys: groupBys,
                limit: limit,
                offset: offset
            ))
        case .manipulation(let statement):
            return .manipulation(.init(
                statement: statement,
                table: table,
                columns: data.convertToDataManipulationColumns(),
                joins: joins,
                predicates: predicates,
                limit: limit
            ))
        }
    }
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
    public static func fluentFilter(_ field: DataColumn, _ method: DataPredicateComparison, _ value: DataPredicateValue) -> DataPredicateItem {
        return .predicate(.init(column: field, comparison: method, value: value))
    }

    public static func fluentFilterGroup(_ relation: DataPredicateGroupRelation, _ filters: [DataPredicateItem]) -> DataPredicateItem {
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

    public static func fluentProperty(_ property: QueryProperty) -> DataPredicateValue {
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
    public func serialize<Q>(_ query: Q) -> String where Q: SQLQuery {
        switch query.convertToDataOrManipulationQuery() {
        case .manipulation(let m): return serialize(query: m)
        case .data(let q): return serialize(query: q)
        }
    }
}

extension DataQueryColumn: QueryKey {
    public typealias AggregateMethod = String

    public static func fluentProperty(_ property: QueryProperty) -> DataQueryColumn {
        return .column(.fluentProperty(property), key: nil)
    }

    public typealias Field = DataColumn

    public static var fluentAll: DataQueryColumn {
        return .all
    }

    public static func fluentAggregate(_ function: String, fields: [DataQueryColumn]) -> DataQueryColumn {
        return .computed(.init(function: function, columns: fields.compactMap { col in
            // FIXME: support nested computed funcs
            switch col {
            case .column(let col, _): return col
            case .computed, .all: return nil
            }
        }), key: "fluentAggregate")
    }
}

extension String: QueryAggregateMethod {
    public static var fluentCount: String {
        return "COUNT"
    }

    public static var fluentSum: String {
        return "SUM"
    }

    public static var fluentAverage: String {
        return "AVERAGE"
    }

    public static var fluentMinimum: String {
        return "MIN"
    }

    public static var fluentMaximum: String {
        return "MAX"
    }


}

extension DataColumn: Hashable, PropertySupporting {
    public var hashValue: Int {
        return (table?.hashValue ?? 0) &+ name.hashValue
    }

    public static func == (lhs: DataColumn, rhs: DataColumn) -> Bool {
        return lhs.table == rhs.table && lhs.name == rhs.name
    }

    public static func fluentProperty(_ property: QueryProperty) -> DataColumn {
        guard let model = property.rootType as? AnyModel.Type else {
            fatalError("`\(property.rootType)` does not conform to `Model`.")
        }
        return .init(table: model.entity, name: property.path.first ?? "")
    }
}

