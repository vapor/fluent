
public protocol Driver {
    func execute(statement: StatementGenerator) -> [[String: StatementValue]]?
}
