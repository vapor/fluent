extension QueryBuilder {
    // MARK: Run

    /// Runs the query, collecting all of the results into an array.
    ///
    ///     let users = User.query(on: conn).all()
    ///
    /// - returns: A `Future` containing the results.
    public func all() -> Future<[Result]> {
        var results: [Result] = []
        return run(.fluentRead) { result in
            results.append(result)
        }.map {
            return results
        }
    }

    /// Returns the first result of the query or `nil` if no results were returned.
    ///
    ///     let users = User.query(on: conn).first()
    ///
    /// - returns: A `Future` containing the first result, if one exists.
    public func first() -> Future<Result?> {
        return range(...1).all().map { $0.first }
    }

    /// Deletes all entities that would be fetched by this query.
    ///
    ///     try User.query(on: conn).filter(\.name == "foo").delete()
    ///
    /// - returns: A `Future` that will be completed when the delete is done.
    public func delete() -> Future<Void> {
        return run(.fluentDelete)
    }

    /// Convenience for chunking model results.
    ///
    ///     try User.query(on: conn).chunk(max: 32) { chunk in
    ///         // handle chunk of 32 or less users
    ///     }
    ///
    /// - parameters:
    ///     - max: Maximum number of entities to include in a single chunk.
    ///            Actual number in chunk may be less than this number if the result set
    ///            is not evenly divisible by the supplied number.
    ///            Note that 0 size chunks may also be supplied.
    ///     - closure: Handles chunks as they are received.
    /// - returns: A `Future` that will be completed when all chunks have been handled.
    public func chunk(max: Int, closure: @escaping ([Result]) throws -> ()) -> Future<Void> {
        var partial: [Result] = []
        partial.reserveCapacity(max)
        return run(.fluentRead) { row in
            partial.append(row)
            if partial.count >= max {
                try closure(partial)
                partial = []
            }
        }.map {
            // any stragglers
            try closure(partial)
            partial = []
        }
    }

    /// Runs the `QueryBuilder's query, decoding results into the handler.
    ///
    ///     User.query(on: req).run { user in
    ///         print(user)
    ///     }
    ///
    /// - parameters:
    ///     - handler: Optional closure to handle results.
    /// - returns: A `Future` that will be completed when the query has finished.
    public func run(_ action: Model.Database.Query.Action, into handler: @escaping (Result) throws -> () = { _ in }) -> Future<Void> {
        // replace action
        query.fluentAction = action

        /// if the model is soft deletable, and soft deleted
        /// models were not requested, then exclude them
        if let type = Model.self as? AnySoftDeletable.Type, !shouldIncludeSoftDeleted, !query.fluentAction.fluentIsCreate {
            let field: Model.Database.Query.Field = .keyPath(any: type.fluentDeletedAtKey, rootType: Model.self, valueType: Date?.self)
            group(.fluentOr) { or in
                or.filter(field, .fluentEqual, Date?.none)
                or.filter(field, .fluentGreaterThan, Date())
            }
        }

        let q = self.query
        let resultTransformer = self.resultTransformer
        return connection.flatMap(to: Void.self) { conn in
            let promise = conn.eventLoop.newPromise(Void.self)

            Model.Database.queryExecute(q, on: conn) { row, conn in
                resultTransformer(row, conn).map { result in
                    return try handler(result)
                    }.catch { error in
                        promise.fail(error: error)
                }
            }.cascade(promise: promise)

            return promise.futureResult
        }
    }
}
