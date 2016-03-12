
public protocol Driver {
    var statementGenerator: StatementGenerator.Type { get }
    func execute(statement: StatementGenerator) -> [[String: StatementValueType]]?
}
