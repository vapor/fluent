
public class PrintDriver: Driver {
    public func execute<T: Model>(query: Query<T>) throws -> [[String : Value]] {
        let sql = SQL(query: query)
        
        print("Statement: \(sql.statement); Values: \(sql.values)")
        
        print("Table \(query.entity)")
        print("Action \(query.action)")
        print("Limits \(query.limit)")
        print("Filters \(query.filters)")
        print("Sorts \(query.sorts)")
        print("Unions \(query.unions)")
        print()
        
        return []
    }
}