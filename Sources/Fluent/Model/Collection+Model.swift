import Async

extension Collection where Element: Model, Element.Database: QuerySupporting {
    /// Saves a collection of models to Database
    ///
    /// - Parameter conn: A means to connect to a database
    /// - Returns: A future array of the saved models
    public func save(on conn: DatabaseConnectable) -> Future<[Element]> {
        return self.map { $0.save(on: conn) }.flatten(on: conn)
    }
}
