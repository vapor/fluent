
public class PrintDriver: Driver {
    public func execute<T: Model>(query: Query<T>) throws -> [[String : Value]] {
        print("FULL QUERY: \(query)")
//        print("PARAMETERIZED QUERY: \(dslContext.parameterizedQuery)")
//        print("QUERY VALUES: \(dslContext.queryValues)")
        print()
        
        return []
    }
}