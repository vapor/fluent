import Vapor

public protocol ModelContent: Content {
    associatedtype ModelType: Model

    init(model: ModelType) throws
}

extension Model where Self: Content {
    public func verifyETag(on req: Request) throws -> Self {
        guard let eTag = try self.eTag() else {
            throw Abort(.internalServerError, reason: "Unable to generate ETag")
        }

        guard let ifMatch = req.headers.firstValue(name: .ifMatch) else {
            throw Abort(.badRequest, reason: "Missing If-Match HTTP Header")
        }

        guard ifMatch == eTag else {
            throw Abort(.preconditionFailed, reason: "Model state is no longer valid.")
        }

        return self
    }
}

extension Model {
    public func verifyETag<DTO>(_ dto: DTO.Type, on req: Request) throws -> Self
        where DTO: ModelContent, DTO.ModelType == Self {
            let dto = try DTO.init(model: self)

            guard let eTag = try dto.eTag() else {
                throw Abort(.internalServerError, reason: "Unable to generate ETag")
            }

            guard let ifMatch = req.headers.firstValue(name: .ifMatch) else {
                throw Abort(.badRequest, reason: "Missing If-Match HTTP Header")
            }

            guard ifMatch == eTag else {
                throw Abort(.preconditionFailed, reason: "Model state is no longer valid.")
            }

            return self
    }
}
