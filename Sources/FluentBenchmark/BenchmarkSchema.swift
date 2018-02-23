import Async
import Dispatch
import Fluent
import Foundation

extension Benchmarker where Database: QuerySupporting & SchemaSupporting {
    /// Benchmark the basic schema creations.
    public func benchmarkSchema() throws {
        let conn = try test(pool.requestConnection())
        try test(KitchenSinkSchema<Database>.prepare(on: conn))
        try test(KitchenSinkSchema<Database>.revert(on: conn))
        pool.releaseConnection(conn)
    }
}
