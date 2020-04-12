import Vapor

extension Response {
    // MARK: - DTO related -

    /// Returns a `Response` with appropriate ETag headers.
    ///
    /// Use this method when you generate a DTO for the model to be returned, and would like to
    /// automatically include the appropriate HTTP ETag header.
    /// - Parameters:
    ///   - dto: The type of DTO which should be generated based on the returned `model`
    ///   - model: The `Model` being returned.
    ///   - status: The HTTP Status code.
    ///   - headers: The HTTP headers to use
    /// - Throws: If the DTO fails to generate.
    /// - Returns: The `Response` object.
    static func withETag<D, M>(
        _ dto: D.Type,
        _ model: M,
        status: HTTPStatus = .ok,
        headers: HTTPHeaders = .init()
    ) throws -> Response where D: ModelContent, M: EntityTaggableModel, M == D.ModelType {
        let response = Response(status: status, headers: headers)
        let content = try dto.init(model: model)
        try response.content.encode(content)

        response.headers.add(name: .eTag, value: model.eTag)

        return response
    }

    /// Returns a `Response` with appropriate ETag and Location headers and an HTTP status of 201 (Created)
    ///
    /// Use this method when you generate a DTO for the model to be returned, and would like to
    /// automatically include the appropriate HTTP ETag and Location headers.
    /// - Parameters:
    ///   - dto: The type of DTO which should be generated based on the returned `model`
    ///   - model: The `Model` being returned.
    ///   - location: The value to place in the HTTP Location header.
    ///   - headers: The HTTP headers to use
    /// - Throws: If the DTO fails to generate.
    /// - Returns: The `Response` object.
    static func createdWithETag<D, M>(
        _ dto: D.Type,
        _ model: M,
        location: String? = nil,
        headers: HTTPHeaders = .init()
    ) throws -> Response where D: ModelContent, M: EntityTaggableModel, M == D.ModelType {
        var headers = headers
        if let location = location {
            headers.add(name: .location, value: location)
        }

        return try withETag(dto, model, status: .created, headers: headers)
    }

    /// Returns a `Response` with appropriate ETag and Location headers and an HTTP status of 201 (Created)
    ///
    /// Use this method when you generate a DTO for the model to be returned, and would like to
    /// automatically include the appropriate HTTP ETag and Location headers.
    /// - Parameters:
    ///   - dto: The type of DTO which should be generated based on the returned `model`
    ///   - model: The `Model` being returned.
    ///   - locationFrom: The `Request` used to generate a default Location header.
    ///   - headers: The HTTP headers to use
    /// - Throws: If the DTO fails to generate.
    /// - Returns: The `Response` object.
    static func createdWithETag<D, M>(
        _ dto: D.Type,
        _ model: M,
        locationFrom req: Request? = nil,
        headers: HTTPHeaders = .init()
    ) throws -> Response where D: ModelContent, M: EntityTaggableModel, M == D.ModelType {
        let location = try req?.location(for: model)

        return try createdWithETag(dto, model, location: location, headers: headers)
    }

    // MARK: - Model related -
    static func withETag<M>(_ model: M, status: HTTPStatus = .ok, headers: HTTPHeaders = .init()) throws -> Response where M: Content & EntityTaggableModel {
        let response = Response(status: status, headers: headers)
        try response.content.encode(model)

        response.headers.add(name: .eTag, value: model.eTag)

        return response
    }

    static func createdWithETag<M>(
        _ model: M,
        location: String? = nil,
        headers: HTTPHeaders = .init()
    ) throws -> Response where M: EntityTaggableModel & Content {
        var headers = headers
        if let location = location {
            headers.add(name: .location, value: location)
        }

        return try withETag(model, status: .created, headers: headers)
    }

    static func createdWithETag<M>(
        _ model: M,
        locationFrom req: Request? = nil,
        headers: HTTPHeaders = .init()
    ) throws -> Response where M: EntityTaggableModel & Content {
        let location = try req?.location(for: model)
        return try createdWithETag(model, location: location, headers: headers)
    }
}

private extension Request {
    func location<M>(for model: M) throws -> String where M: Model {
        let id = try String(describing: model.requireID())
        return "\(self.url.string)/\(id)"
    }
}
