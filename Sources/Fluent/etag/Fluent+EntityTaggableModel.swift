import Vapor

public extension EventLoopFuture where Value: EntityTaggableModel {
    /// Verifies that the ETag stored in the database matches the ETag passed via the `If-Match` HTTP header.
    /// - Parameters:
    ///   - req: The `Request` object.
    func verifyETag(on req: Request) -> EventLoopFuture<Value> {
        return self.flatMapThrowing { model -> Value in
            guard let ifMatch = req.headers.first(name: .ifMatch) else {
                throw Abort(.badRequest, reason: "Missing If-Match HTTP Header.")
            }

            guard ifMatch == model.eTag else {
                throw Abort(.preconditionFailed, reason: "Model state is no longer valid.")
            }

            return model
        }
    }
}
