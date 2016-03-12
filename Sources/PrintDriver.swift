
public class PrintDriver: Driver {
    public var statementGenerator: StatementGenerator.Type {
        return SQL.self
    }
    
    public func execute(statement: StatementGenerator) -> [[String : StatementValueType]]? {
        print("FULL QUERY: \(statement.query)")
        print("PARAMETERIZED QUERY: \(statement.parameterizedQuery)")
        print("QUERY VALUES: \(statement.queryValues)")
        print()
        return nil
    }
}