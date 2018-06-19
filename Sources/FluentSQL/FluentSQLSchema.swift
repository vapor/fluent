public protocol FluentSQLSchema {
    associatedtype Statement: FluentSQLSchemaStatement
    associatedtype TableIdentifier: SQLTableIdentifier
    associatedtype ColumnDefinition: SQLColumnDefinition
    associatedtype TableConstraint: SQLTableConstraint
    associatedtype ColumnIdentifier: SQLColumnIdentifier
    
    var statement: Statement { get set }
    var table: TableIdentifier { get set }
    var columns: [ColumnDefinition] { get set }
    var deleteColumns: [ColumnIdentifier] { get set }
    var constraints: [TableConstraint] { get set }
    var deleteConstraints: [TableConstraint] { get set }
    
    static func schema(_ statement: Statement, _ table: TableIdentifier) -> Self
}


public protocol FluentSQLSchemaStatement {
    static var createTable: Self { get }
    static var alterTable: Self { get }
    static var dropTable: Self { get }
}
