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
        stream.drain { row in
            rows.append(row)
        }.catch { error in
            promise.fail(error)
        }.finally {
            promise.complete(rows)
        }

        return stream.prepare().flatMap(to: [Model].self) {
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

        stream.drain { _ in
            // ignore output
        }.catch { err in
            promise.fail(err)
        }.finally {
            promise.complete()
        }

        return stream.prepare().flatMap(to: Void.self) {
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
        stream.drain { row in
            partial.append(row)
            if partial.count >= max {
                try closure(partial)
                partial = []
            }
        }.catch { error in
            promise.fail(error)
        }.finally {
            do {
                try closure(partial)
                partial = []
                promise.complete()
            } catch {
                promise.fail(error)
            }
        }

        return stream.prepare().flatMap(to: Void.self) {
            return promise.future
        }
    }
}

