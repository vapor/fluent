
public class PrintDriver: Driver {
    public func execute(dslContext: DSGenerator) -> [[String : Value]]? {
        print("FULL QUERY: \(dslContext.query)")
        print("PARAMETERIZED QUERY: \(dslContext.parameterizedQuery)")
        print("QUERY VALUES: \(dslContext.queryValues)")
        print()
        return nil
    }
}