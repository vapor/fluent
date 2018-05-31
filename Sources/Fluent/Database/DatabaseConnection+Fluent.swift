extension DatabaseConnection {
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
