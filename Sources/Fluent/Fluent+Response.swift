import Vapor

extension Response {
    /// Creates a `Response` object that has a status of 201 (Created) and includes the `Location` HTTP header.
    ///
    /// Intended to be used in routes that create a new object.
    ///
    /// ### Note ###
    /// The return type of your route should be `EventLoopFuture<Response>`.
    ///
    /// ### Example ###
    /// ```swift
    /// func create(req: Request) throws -> EventLoopFuture<Response> {
    ///    let todo = try req.content.decode(Todo.self)
    ///    return todo.create(on: req.db).flatMapThrowing {
    ///        try .created(todo, for: req)
    ///    }
    /// }
    /// ```
    /// - Parameters:
    ///   - obj: The newly created model.
    ///   - request: The `Request` which is being responded to.
    ///   - mediaType: How to encode the response, defaulting to `.json`
    /// - Throws: If the object hasn't been created or the encoding fails.
    /// - Returns: A `Response` object.
    public static func created<T>(
        _ obj: T,
        for request: Request,
        as mediaType: HTTPMediaType = .json
    ) throws -> Response
        where T: Model & Content, T.IDValue: CustomStringConvertible {
            let id = String(describing: try obj.requireID())

            return try self.created(obj, for: request, id: id, as: mediaType)
    }

    /// Creates a `Response` object that has a status of 201 (Created) and includes the `Location` HTTP header.
    ///
    /// Intended to be used in routes that create a new object. Many models contain the actual `id` which
    /// is the primary key in the database as an `Int`, but then also include a public identifier like a `UUID`
    /// that consumers utilize. This is simply a convenience method to return that public ID in the `Location` header.
    ///
    /// ### Note ###
    /// The return type of your route should be `EventLoopFuture<Response>`.
    ///
    /// ### Example ###
    /// ```swift
    /// func create(req: Request) throws -> EventLoopFuture<Response> {
    ///    let todo = try req.content.decode(Todo.self)
    ///    return todo.create(on: req.db).flatMapThrowing {
    ///        try .created(todo, for: req, id: todo.publicUUID.uuidString)
    ///    }
    /// }
    /// ```
    /// - Parameters:
    ///   - obj: The newly created model.
    ///   - request: The `Request` which is being responded to.
    ///   - id: The user visible ID that the model should be queried against.
    ///   - mediaType: How to encode the response, defaulting to `.json`
    /// - Throws: If the object hasn't been created or the encoding fails.
    /// - Returns: A `Response` object.
    public static func created<T, ID>(
        _ obj: T,
        for request: Request,
        id: ID,
        as mediaType: HTTPMediaType = .json
    ) throws -> Response
        where T: Content, ID: CustomStringConvertible {
            let id = String(describing: id)
            let location = "\(request.url.string)/\(id)"

            return try self.created(obj, location: location, as: mediaType)
    }

    /// Creates a `Response` object that has a status of 201 (Created) and includes the `Location` HTTP header.
    ///
    /// Intended to be used in routes that create a new object.
    ///
    /// ### Note ###
    /// The return type of your route should be `EventLoopFuture<Response>`.
    ///
    /// ### Example ###
    /// ```swift
    /// func create(req: Request) throws -> EventLoopFuture<Response> {
    ///    let todo = try req.content.decode(Todo.self)
    ///    return todo.create(on: req.db).flatMapThrowing {
    ///        let uuid = todo.publicUUID
    ///        return try .created(todo, location: "\(req.url.string)/\(uuid)")
    ///    }
    /// }
    /// ```
    /// - Parameters:
    ///   - obj: The newly created model.
    ///   - location: The location header to use.
    ///   - mediaType: How to encode the response, defaulting to `.json`
    /// - Throws: If the encoding fails.
    /// - Returns: A `Response` object.
    public static func created<T>(
        _ obj: T,
        location: String,
        as mediaType: HTTPMediaType = .json
    ) throws -> Response
        where T: Content {
            let hash = try Insecure.MD5.hash(data: JSONEncoder().encode(obj))
            let etag = hash.map { String(format: "%02hhx", $0) }.joined(separator: "")
            let headers = HTTPHeaders([("Location", location), ("ETag", "\"\(etag)\"")])
            let response = Response(status: .created, headers: headers)

            try response.content.encode(obj, as: mediaType)

            return response
    }
}

