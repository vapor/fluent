#if compiler(>=5.5) && canImport(_Concurrency)
import NIOCore
import Vapor
import FluentKit

@available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
extension QueryBuilder {
    public func paginate(
        for request: Request
    ) async throws -> Page<Model> {
        let page = try request.query.decode(PageRequest.self)
        return try await self.paginate(page)
    }
}

#endif
