import FluentKit
public import Vapor

extension QueryBuilder {
    public func paginate(
        for request: Request
    ) async throws -> Page<Model> {
        let page = try request.query.decode(PageRequest.self)
        return try await self.paginate(page).get()
    }
}
