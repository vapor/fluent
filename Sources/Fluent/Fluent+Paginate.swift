import Vapor
import FluentKit

extension QueryBuilder {
    public func paginate(
        for request: Request
    ) -> EventLoopFuture<Page<Model>> {
        do {
            let page = try request.query.decode(PageRequest.self)
            return self.paginate(page)
        } catch {
            return request.eventLoop.makeFailedFuture(error)
        }
    }
}

extension Page: Content, ResponseEncodable, RequestDecodable, AsyncResponseEncodable, AsyncRequestDecodable where T: Codable { }
