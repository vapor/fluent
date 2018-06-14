//// MARK: Model
//
//extension Model {
//    /// Temporarily deletes a soft deletable model. This model can be restored using `restore(on:)`.
//    ///
//    ///     user.softDelete(on: req)
//    ///
//    /// - parameters:
//    ///     - conn: Used to fetch a database connection.
//    /// - returns: A future that will be completed when the force delete finishes.
//    public func softDelete(on conn: DatabaseConnectable) -> Future<Void> {
//        return Self.query(on: conn).softDelete(self)
//    }
//}
//
///// MARK: Future Model
//
//extension Future where T: Model {
//    /// See `SoftDeletable`.
//    public func softDelete(on conn: DatabaseConnectable) -> Future<Void> {
//        return flatMap(to: Void.self) { model in
//            return model.softDelete(on: conn)
//        }
//        
//    }
//
//    /// See `SoftDeletable`.
//    public func restore(on conn: DatabaseConnectable) -> Future<T> {
//        return flatMap(to: T.self) { model in
//            return model.restore(on: conn)
//        }
//    }
//}
