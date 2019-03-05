import Async

extension Collection where Element: Model, Element.Database: TransactionSupporting {
    /// Saves a collection of models to Database
    ///
    /// - Parameter conn: A means to connect to a database
    /// - Returns: A future array of the saved models
    func save(on conn: Element.Database.Connection) -> Future<[Element]> {
        return self.map { $0.save(on: conn) }.flatten(on: conn)
    }
    
    /// Updates a collection of models in Database
    ///
    /// - Parameter conn: A means to connect to a database
    /// - Returns: A future array of the updated models
    public func update(on conn: DatabaseConnectable) -> Future<[Element]> {
        return self.map { $0.update(on: conn) }.flatten(on: conn)
    }
    
    /// Creates a collection of models in Database
    ///
    /// - Parameter conn: A means to connect to a database
    /// - Returns: A future array of the created models
    func create(on conn: Element.Database.Connection) -> Future<[Element]> {
        return self.map { $0.create(on: dbConn) }.flatten(on: dbConn)
    }
    
    /// Deletes a collection of models from Database
    ///
    /// - Parameter conn: A means to connect to a database
    /// - Returns: A future array of the deleted models
    func delete(on conn: Element.Database.Connection) -> Future<[Element]> {
        return element.delete(on: dbConn).transform(to: element)
    }
}
