import Async
import DatabaseKit

extension DatabaseConnection {
    /// Create a query for the specified model using this connection.
    public func query<M>(_ model: M.Type) -> QueryBuilder<M, M>
        where M.Database.Connection == Self
    {
        return M.query(on: Future.map(on: self) { self })
    }
}

fileprivate final class PipelineCache {
    var storage: [ObjectIdentifier: Future<Void>]
    init() { storage = [:] }
}

fileprivate var pipelineCache: ThreadSpecificVariable<PipelineCache> = .init()

extension DatabaseConnection {
    fileprivate var pipeline: Future<Void> {
        get {
            let cache: PipelineCache
            if let existing = pipelineCache.currentValue {
                cache = existing
            } else {
                cache = .init()
                pipelineCache.currentValue = cache
            }

            let pipeline: Future<Void>
            if let existing = cache.storage[.init(self)] {
                pipeline = existing
            } else {
                pipeline = Future.map(on: self) { }
                cache.storage[.init(self)] = pipeline
            }
            return pipeline
        }
        set {
            let cache: PipelineCache
            if let existing = pipelineCache.currentValue {
                cache = existing
            } else {
                cache = .init()
                pipelineCache.currentValue = cache
            }
            cache.storage[.init(self)] = newValue
        }
    }

    /// Enqueues a Fluent operation.
    internal func fluentOperation<T>(_ work: @escaping () -> Future<T>) -> Future<T> {
        /// perform this work when the current pipeline future is completed
        let new = pipeline.flatMap(to: T.self) {
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
}
