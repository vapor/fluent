/**
    A dummy `Driver` useful for developing.
*/
public class PrintDriver: Driver {
    public var idKey: String = "foo"
    
    public func query<T: Model>(_ query: Query<T>) throws -> [[String : Value]] {

        let sql = SQL(query: query)
        let serializer = GeneralSQLSerializer(sql: sql)

        let (statement, values) = serializer.serialize()
        print("[Print driver]")
        
        print("Statement: \(statement) Values: \(values)")
        
        print("Table \(query.entity)")
        print("Action \(query.action)")
        print("Filters \(query.filters)")
        print()
        
        return []
    }

    public func schema(_ schema: Schema) throws {
        //let sql = SQL(builder: builder)
    }
}