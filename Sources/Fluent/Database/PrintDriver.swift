/**
    A dummy `Driver` useful for developing.
*/
public class PrintDriver: Driver {
    public var idKey: String = "foo"
    
    public func query<T: Entity>(_ query: Query<T>) throws -> Node {

        let sql = SQL(query: query)
        let serializer = GeneralSQLSerializer(sql: sql)

        let (statement, values) = serializer.serialize()
        print("[Print driver]")
        
        print("Statement: \(statement) Values: \(values)")
        
        print("Table \(query.entity)")
        print("Action \(query.action)")
        print("Filters \(query.filters)")
        print()
        
        return .null
    }

    public func schema(_ schema: Schema) throws {
        //let sql = SQL(builder: builder)
    }

    public func raw(_ raw: String, _ values: [Node]) throws -> Node {
        return .null
    }
}
