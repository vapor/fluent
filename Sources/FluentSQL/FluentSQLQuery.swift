public protocol FluentSQLQuery {
    associatedtype Statement: FluentSQLQueryStatement
    associatedtype Expression: SQLExpression
    associatedtype Join: SQLJoin
    associatedtype OrderBy: SQLOrderBy
    associatedtype GroupBy: SQLGroupBy
    associatedtype TableIdentifier: SQLTableIdentifier
    associatedtype SelectExpression: SQLSelectExpression
    
    var statement: Statement { get set }
    var table: TableIdentifier { get set }
    var keys: [SelectExpression] { get set }
    var predicate: Expression? { get set }
    var joins: [Join] { get set }
    var orderBy: [OrderBy] { get set }
    var groupBy: [GroupBy] { get set }
    var limit: Int? { get set }
    var offset: Int? { get set }
    var values: [String: Expression] { get set }
    var defaultBinaryOperator: Expression.BinaryOperator { get set }
    
    static func query(_ statement: Statement, _ table: TableIdentifier) -> Self
}

public protocol FluentSQLQueryStatement {
    static var insert: Self { get }
    static var select: Self { get }
    static var update: Self { get }
    static var delete: Self { get }
    var isInsert: Bool { get }
}
