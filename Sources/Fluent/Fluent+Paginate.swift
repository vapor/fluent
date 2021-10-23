import Vapor

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

#if compiler(>=5.5) && canImport(_Concurrency)
extension Page: Content, ResponseEncodable, RequestDecodable, AsyncResponseEncodable, AsyncRequestDecodable where T: Codable { }
#else
extension Page: Content, ResponseEncodable, RequestDecodable where T: Codable { }
#endif
