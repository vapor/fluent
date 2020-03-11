import Fluent
import Vapor
import XCTVapor

final class FluentCreatedTests: XCTestCase {
    // ETags are supposed to be hex strings surrounded by double quotes
    static let eTagRegex = "^\"[a-fA-F0-9]+\"$"

    func testWithCustomLocation() throws {
        let headerString = UUID().uuidString
        let response = try Response.created(Todo(), location: headerString)
        let location = try XCTUnwrap(response.headers.firstValue(name: .location))
        let etag = try XCTUnwrap(response.headers.firstValue(name: .eTag))
        XCTAssertNotNil(etag.range(of: Self.eTagRegex, options: .regularExpression))
        XCTAssertEqual(location, headerString)
        XCTAssertEqual(response.status, HTTPStatus.created)
    }

    func testWithRequest() throws {
        let todo = Todo()

        let uri = URI(path: "https://www.example.com/todos")
        let app = Application(.testing)
        defer { app.shutdown() }

        let req = Request(application: app, method: .POST, url: uri, on: app.eventLoopGroup.next())

        let response = try Response.created(todo, for: req)
        let location = try XCTUnwrap(response.headers.firstValue(name: .location))
        let etag = try XCTUnwrap(response.headers.firstValue(name: .eTag))
        XCTAssertNotNil(etag.range(of: Self.eTagRegex, options: .regularExpression))
        XCTAssertNotNil(response.headers.firstValue(name: .eTag))
        XCTAssertEqual(location, "\(uri.string)/\(todo.id!)")
        XCTAssertEqual(response.status, HTTPStatus.created)
    }

    func testWithPublicID() throws {
        let todo = Todo()

        let uri = URI(path: "https://www.example.com/todos")
        let app = Application(.testing)
        defer { app.shutdown() }

        let req = Request(application: app, method: .POST, url: uri, on: app.eventLoopGroup.next())

        let response = try Response.created(todo, for: req, id: todo.publicUUID)
        let location = try XCTUnwrap(response.headers.firstValue(name: .location))
        let etag = try XCTUnwrap(response.headers.firstValue(name: .eTag))
        XCTAssertNotNil(etag.range(of: Self.eTagRegex, options: .regularExpression))
        XCTAssertNotNil(response.headers.firstValue(name: .eTag))
        XCTAssertEqual(location, "\(uri.string)/\(todo.publicUUID)")
        XCTAssertEqual(response.status, HTTPStatus.created)
    }
}

private final class Todo: Model, Content {
    static let schema = ""

    @ID(key: .id)
    var id: UUID?

    @Field(key: "uuid")
    var publicUUID: UUID

    init() {
        self.id = UUID()
        self.publicUUID = UUID()
    }
}
