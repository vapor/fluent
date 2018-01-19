import Async

/// Execute the database query.
extension QueryBuilder {
    /// Executes the query, collecting the results
    /// into an array.
    /// The resulting array or an error will be resolved
    /// in the returned future.
    public func all() -> Future<[Model]> {
        let stream = run()

        let promise = Promise([Model].self)

        // cache the rows
        var rows: [Model] = []

        // drain the stream of results
        let drain = stream.drain { row, upstream in
            rows.append(row)
            upstream.request()
        }.catch { error in
            promise.fail(error)
        }.finally {
            promise.complete(rows)
        }

        return stream.prepare().flatMap(to: [Model].self) {
            drain.upstream?.request()
            return promise.future
        }
    }

    /// Returns a future with the first result of the query.
    /// `nil` if no results were returned.
    public func first() -> Future<Model?> {
        return range(...1).all().map(to: Model?.self) { $0.first }
    }

    /// Runs a delete operation.
    public func delete() -> Future<Void> {
        query.action = .delete
        return execute()
    }

    /// Runs the query, ignoring output.
    public func execute() -> Future<Void> {
        let promise = Promise(Void.self)

        let stream = run()

        let drain = stream.drain { _, upstream in
            // ignore output
            upstream.request()
        }.catch { err in
            promise.fail(err)
        }.finally {
            promise.complete()
        }

        return stream.prepare().flatMap(to: Void.self) {
            drain.upstream?.request()
            return promise.future
        }
    }
}

// MARK: Chunk

extension QueryBuilder {
    /// Accepts a chunk of models.
    public typealias ChunkClosure<T> = ([T]) throws -> ()

    /// Convenience for chunking model results.
    public func chunk(
        max: Int, closure: @escaping ChunkClosure<Model>
    ) -> Future<Void> {
        return chunk(decoding: Model.self, max: max, closure: closure)
    }

    /// FIXME: move this to async
    /// Run the query, grouping the results into chunks before calling closure.
    public func chunk<T: Decodable>(
        decoding type: T.Type = T.self,
        max: Int, closure: @escaping ChunkClosure<T>
    ) -> Future<Void> {
        var partial: [T] = []
        partial.reserveCapacity(max)

        let promise = Promise(Void.self)

        let stream = run(decoding: T.self)

        // drain the stream of results
        let drain = stream.drain { row, upstream in
            partial.append(row)
            if partial.count >= max {
                try closure(partial)
                partial = []
            }
            upstream.request()
        }.catch { error in
            promise.fail(error)
        }.finally {
            if partial.count > 0 {
                do {
                    try closure(partial)
                } catch {
                    promise.fail(error)
                }
            }
            promise.complete()
        }

        return stream.prepare().flatMap(to: Void.self) {
            drain.upstream?.request()
            return promise.future
        }
    }
}

