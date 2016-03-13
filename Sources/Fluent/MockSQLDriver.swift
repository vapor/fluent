public class MockSQLDriver: Driver {
    public func execute(statement: StatementGenerator) -> [[String : StatementValue]]? {
        return nil
    }
}