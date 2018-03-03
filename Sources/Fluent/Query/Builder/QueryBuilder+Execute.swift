import Async

/// Execute the database query.
extension QueryBuilder {
    /// Runs the query, collecting all of the results into an array.
    public func all<D>(decoding type: D.Type) -> Future<[D]> where D: Decodable {
        var rows: [D] = []
        return run(decoding: D.self) { model, conn in
            rows.append(model)
        }.map(to: [D].self) {
            return rows
        }
    }

    /// Runs the query, collecting all of the results into an array.
    public func all() -> Future<[Model]> {
        var rows: [Model] = []
        return run() { model, conn in
            rows.append(model)
        }.map(to: [Model].self) {
            return rows
        }
    }

    /// Returns the first result of the query or `nil` if no results were returned.
    public func first<D>(decoding type: D.Type) -> Future<D?>  where D: Decodable {
        return range(...1).all(decoding: D.self).map(to: D?.self) { $0.first }
    }

    /// Returns the first result of the query or `nil` if no results were returned.
    public func first() -> Future<Model?> {
        return range(...1).all().map(to: Model?.self) { $0.first }
    }

    /// Runs a delete operation.
    public func delete() -> Future<Void> {
        query.action = .delete
        return run()
    }
}

// MARK: Chunk

extension QueryBuilder {
    /// Convenience for chunking model results.
    public func chunk(max: Int, closure: @escaping ([Model]) throws -> ()) -> Future<Void> {
        return chunk(decoding: Model.self, max: max, closure: closure)
    }

    /// Run the query, grouping the results into chunks before calling closure.
    public func chunk<D>(decoding type: D.Type, max: Int, closure: @escaping ([D]) throws -> ()) -> Future<Void>
        where D: Decodable
    {
        var partial: [D] = []
        partial.reserveCapacity(max)
        return run(decoding: D.self) { row, conn in
            partial.append(row)
            if partial.count >= max {
                try closure(partial)
                partial = []
            }
        }.map(to: Void.self) {
            // any stragglers
            try closure(partial)
            partial = []
        }
    }
}

