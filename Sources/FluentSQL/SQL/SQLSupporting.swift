extension DatabasesConfig {
    public mutating func enableForeignKeys<D>(on db: DatabaseIdentifier<D>) where D: SchemaSupporting {
        appendConfigurationHandler(on: db) { D.enableForeignKeys(on: $0) }
    }
    
    public mutating func disableForeignKeys<D>(on db: DatabaseIdentifier<D>) where D: SchemaSupporting {
        appendConfigurationHandler(on: db) { D.disableForeignKeys(on: $0) }
    }
}


/// SQL database.
public protocol SchemaSupporting: QuerySupporting {
    associatedtype Schema
    associatedtype SchemaAction
    associatedtype SchemaField
    associatedtype SchemaFieldType
    associatedtype SchemaConstraint
    associatedtype SchemaReferenceAction
    
    static var schemaActionCreate: SchemaAction { get }
    static var schemaActionUpdate: SchemaAction { get }
    static var schemaActionDelete: SchemaAction { get }
    
    static func schemaCreate(_ action: SchemaAction, _ entity: String) -> Schema
    
    static func schemaField(for type: Any.Type, isIdentifier: Bool, _ field: QueryField) -> SchemaField
    
    static func schemaField(_ field: QueryField, _ type: SchemaFieldType) -> SchemaField
    
    static func schemaFieldCreate(_ field: SchemaField, to query: inout Schema)
    
    static func schemaFieldDelete(_ field: QueryField, to query: inout Schema)
    
    static func schemaReference(from: QueryField, to: QueryField, onUpdate: SchemaReferenceAction?, onDelete: SchemaReferenceAction?) -> SchemaConstraint
    
    static func schemaUnique(on: [QueryField]) -> SchemaConstraint
    
    static func schemaConstraintCreate(_ constraint: SchemaConstraint, to query: inout Schema)
    
    static func schemaConstraintDelete(_ constraint: SchemaConstraint, to query: inout Schema)

    /// Executes the supplied schema on the database connection.
    static func schemaExecute(_ schema: Schema, on conn: Connection) -> Future<Void>

    /// Enables references errors.
    static func enableForeignKeys(on conn: Connection) -> Future<Void>

    /// Disables reference errors.
    static func disableForeignKeys(on conn: Connection) -> Future<Void>
}

extension SchemaSupporting {
//    // MARK: Action
//
//    /// See `QuerySupporting.`
//    public static var queryActionCreate: QueryAction {
//        return .insert
//    }
//
//    /// See `QuerySupporting.`
//    public static var queryActionRead: QueryAction {
//        return .select
//    }
//
//    /// See `QuerySupporting.`
//    public static var queryActionUpdate: QueryAction {
//        return .update
//    }
//
//    /// See `QuerySupporting.`
//    public static var queryActionDelete: QueryAction {
//        return .delete
//    }
//
//    /// See `QuerySupporting.`
//    public static func queryActionIsCreate(_ statement: QueryAction) -> Bool {
//        switch statement.verb {
//        case "INSERT": return true
//        default: return false
//        }
//    }
//
//    /// See `QuerySupporting.`
//    public static func queryActionApply(_ statement: QueryAction, to query: inout Query) {
//        query.statement = statement
//    }
//
//    // MARK: Aggregate
//
//    /// See `QuerySupporting.`
//    public static var queryAggregateCount: QueryAggregate {
//        return "COUNT"
//    }
//
//    /// See `QuerySupporting.`
//    public static var queryAggregateSum: QueryAggregate {
//        return "SUM"
//    }
//
//    /// See `QuerySupporting.`
//    public static var queryAggregateAverage: QueryAggregate {
//        return "AVERAGE"
//    }
//
//    /// See `QuerySupporting.`
//    public static var queryAggregateMinimum: QueryAggregate {
//        return "MIN"
//    }
//
//    /// See `QuerySupporting.`
//    public static var queryAggregateMaximum: QueryAggregate {
//        return "MAX"
//    }
//
//    /// See `QuerySupporting.`
//    public static func queryAggregate(_ function: String, _ keys: [QueryKey]) -> QueryKey {
//        return .computed(.init(function: function, keys: keys), as: "fluentAggregate")
//    }
//
//    /// See `QuerySupporting.`
//    public static func query(_ entity: String) -> Query {
//        return .init(statement: .select, table: entity)
//    }
//
//    /// See `QuerySupporting.`
//    public static func queryEntity(for query: Query) -> String {
//        return query.table
//    }
//
//    // MARK: Data
//
//    public static func queryDataApply(_ columns: QueryData, to query: inout Query) {
//        query.columns = columns
//    }
//
//    public static func queryDataSet(_ field: QueryField, to data: Encodable, on query: inout Query) {
//        query.columns[field] = .bind(data)
//    }
//
//    // MARK: Field
//
//    public static func queryField(_ property: FluentProperty) -> QueryField {
//        return .fluentProperty(property)
//    }
//
//    // MARK: Filter
//
//    public static var queryFilterMethodEqual: QueryFilterMethod {
//        return .equal
//    }
//
//    public static var queryFilterMethodNotEqual: QueryFilterMethod {
//        return .notEqual
//    }
//
//    public static var queryFilterMethodGreaterThan: QueryFilterMethod {
//        return .greaterThan
//    }
//
//    public static var queryFilterMethodLessThan: QueryFilterMethod {
//        return .lessThan
//    }
//
//    public static var queryFilterMethodGreaterThanOrEqual: QueryFilterMethod {
//        return .greaterThanOrEqual
//    }
//
//    public static var queryFilterMethodLessThanOrEqual: QueryFilterMethod {
//        return .lessThanOrEqual
//    }
//
//    public static var queryFilterMethodInSubset: QueryFilterMethod {
//        return .in
//    }
//
//    public static var queryFilterMethodNotInSubset: QueryFilterMethod {
//        return .notIn
//    }
//
//    public static func queryFilterValue(_ encodables: [Encodable]) -> QueryFilterValue {
//        return .binds(encodables)
//    }
//
//    public static var queryFilterValueNil: QueryFilterValue {
//        return .null
//    }
//
//    public static func queryFilters(for query: Query) -> [QueryFilter] {
//        return query.predicates
//    }
//
//    public static func queryFilterApply(_ filter: QueryFilter, to query: inout Query) {
//        query.predicates.append(filter)
//    }
//
//    public static func queryFilter(_ column: QueryField, _ comparison: QueryFilterMethod, _ value: QueryFilterValue) -> QueryFilter {
//        return .predicate(column, comparison, value)
//    }
//
//    public static var queryFilterRelationAnd: QueryFilterRelation {
//        return .and
//    }
//
//    public static var queryFilterRelationOr: QueryFilterRelation {
//        return .or
//    }
//
//    public static func queryFilterGroup(_ relation: QueryFilterRelation, _ predicates: [QueryFilter]) -> QueryFilter {
//        return .group(relation, predicates)
//    }
//
//    // MARK: Join
//
//    /// See `SchemaSupporting`.
//    public static var queryJoinMethodDefault: QueryJoinMethod {
//        return .inner
//    }
//
//    /// See `SchemaSupporting`.
//    public static func queryJoin(_ method: QueryJoinMethod, base: QueryField, joined: QueryField) -> QueryJoin {
//        return .init(method: method, local: base, foreign: joined)
//    }
//
//    /// See `SchemaSupporting`.
//    public static func queryJoinApply(_ join: QueryJoin, to query: inout Query) {
//        query.joins.append(join)
//    }
//
//    // MARK: Key
//
//    public static var queryKeyAll: QueryKey {
//        return .all(table: nil)
//    }
//
//    public static func queryKey(_ column: QueryField) -> QueryKey {
//        return .column(column)
//    }
//
//    public static func queryKeyApply(_ key: QueryKey, to query: inout Query) {
//        query.keys.append(key)
//    }
//
//    // MARK: Range
//
//    public static func queryRangeApply(lower: Int, upper: Int?, to query: inout Query) {
//        query.offset = lower
//        if let upper = upper {
//            query.limit = upper - lower
//        }
//    }
//
//    // MARK: Sort
//
//    public static func querySort(_ column: QueryField, _ direction: QuerySortDirection) -> QuerySort {
//        return .init(columns: [column], direction: direction)
//    }
//
//    public static var querySortDirectionAscending: QuerySortDirection {
//        return .ascending
//    }
//
//    public static var querySortDirectionDescending: QuerySortDirection {
//        return .descending
//    }
//
//    public static func querySortApply(_ orderBy: QuerySort, to query: inout Query) {
//        query.orderBys.append(orderBy)
//    }
//
//    // MARK: Encode
//
//    /// See `SQLDatabase`.
//    public static func queryEncode<E>(_ encodable: E, entity: String) throws -> QueryData where E: Encodable {
//        return try SQLRowEncoder<Self>().encode(encodable, tableName: entity)
//    }

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
        return schemaExecute(Model.Database.schemaCreate(Model.Database.schemaActionDelete, Model.entity), on: conn)
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
