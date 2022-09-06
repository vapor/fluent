#if compiler(>=5.5) && canImport(_Concurrency)
import NIOCore
import Vapor

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension QueryBuilder {
    public func paginate(
        for request: Request
    ) async throws -> Page<Model> {
        let page = try request.query.decode(PageRequest.self)
        return try await self.paginate(page)
    }
}

#endif
