/**
    A `Driver` execute queries
    and returns an array of results.
    It is responsible 
*/
public protocol Driver {
    /**

    */
    var idKey: String { get }
    func execute<T: Model>(_ query: Query<T>) throws -> [[String: Value]]
}
