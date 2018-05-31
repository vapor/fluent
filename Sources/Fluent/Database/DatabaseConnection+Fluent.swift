extension DatabaseConnection {
    /// Create a `QueryBuilder` for the specified `Model` using this connection.
    public func query<Model>(_ model: Model.Type) -> QueryBuilder<Model.Database, Model>
        where Model: Fluent.Model, Model.Database.Connection == Self
    {
        return Model.query(on: eventLoop.newSucceededFuture(result: self))
    }

    /// Enqueues a Fluent operation. Enqueued operations are guaranteed to run in order, synchronously.
    /// This is useful for performing multiple queries that must happen in order, like creating a new entity
    /// and fetching its ID.
    ///
    ///     conn.fluentOperation {
    ///         return conn.doA().flatMap {
    ///             return conn.doB()
    ///         }
    ///     }
    ///
    internal func fluentOperation<T>(_ work: @escaping () -> Future<T>) -> Future<T> {
        /// perform this work when the current pipeline future is completed
        let new = pipeline.flatMap {
            work()
        }

        /// append this work to the pipeline, discarding errors as the pipeline
        /// does not care about them
        pipeline = new.transform(to: ()).catchMap { err in
            return ()
        }

        /// return the newly enqueued work's future result
        return new
    }

    /// The current pipeline future.
    private var pipeline: Future<Void> {
        get { return extend.get(\Self.pipeline, default: .done(on: self)) }
        set { extend.set(\Self.pipeline, to: newValue) }
    }
}

extension DatabaseConnectable {
    public func query<Database, Result>(_ result: Result.Type, at entity: String, on db: DatabaseIdentifier<Database>) -> QueryBuilder<Database, Result>
        where Result: Decodable
    {
        return QueryBuilder<Database, Database.Output>.raw(entity: entity, on: databaseConnection(to: db)).decode(Result.self, at: entity)
    }
    
    public func query<Database, Result>(_ model: Result.Type, on db: DatabaseIdentifier<Database>) -> QueryBuilder<Database, Result>
        where Result: Model
    {
        return QueryBuilder<Database, Database.Output>.raw(entity: Result.entity, on: databaseConnection(to: db)).decode(Result.self)
    }
}


extension Decodable {
    public static func query<C>(_ entity: String, on conn: C) -> QueryBuilder<C.Database, Self>
        where C: DatabaseConnection
    {
        return QueryBuilder<C.Database, C.Database.Output>.raw(entity: entity, on: conn.future(conn)).decode(Self.self, at: entity)
    }
}
