public class MockSQLDriver: Driver {
    public func execute(dslContext: DSGenerator) -> [[String : StatementValue]]? {
        return nil
    }
}