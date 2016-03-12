
public protocol Driver {
    var statementClass: StatementGenerator.Type { get }
    func execute(statement: StatementGenerator) -> [[String: StatementValueType]]?
}