
public class PrintDriver: Driver {
    public func execute(statement: StatementGenerator) -> [[String : StatementValue]]? {
        print("FULL QUERY: \(statement.query)")
        print("PARAMETERIZED QUERY: \(statement.parameterizedQuery)")
        print("QUERY VALUES: \(statement.queryValues)")
        print()
        return nil
    }
}