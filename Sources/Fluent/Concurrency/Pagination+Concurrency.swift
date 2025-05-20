import NIOCore
import Vapor
import FluentKit
import SQLKit

extension QueryBuilder {
    public func paginate(
        for request: Request,
        annotationContext: SQLAnnotationContext? = nil
    ) async throws -> Page<Model> {
        let page = try request.query.decode(PageRequest.self)
        return try await self.paginate(page, annotationContext: annotationContext)
    }
}
