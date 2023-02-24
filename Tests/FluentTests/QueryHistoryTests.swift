import Fluent
import Vapor
import XCTFluent
import XCTVapor
import FluentKit

final class QueryHistoryTests: XCTestCase {
    func testQueryHistoryDisabled() throws {
        let app = Application(.testing)
        defer { app.shutdown() }

        let test = ArrayTestDatabase()
        app.databases.use(test.configuration, as: .test)

        test.append([
            TestOutput(["id": 1, "content": "a"]),
            TestOutput(["id": 2, "content": "b"]),
        ])

        app.get("foo") { req -> EventLoopFuture<[Post]> in
            return Post.query(on: req.db).all().map { posts in
                XCTAssertEqual(req.fluent.history.queries.count, 0)
                return posts
            }
        }

        try app.testable().test(.GET, "foo") { res in
            XCTAssertEqual(res.status, .ok)
        }
    }

    func testQueryHistoryEnabled() throws {
        let app = Application(.testing)
        defer { app.shutdown() }

        let test = ArrayTestDatabase()
        app.databases.use(test.configuration, as: .test)

        test.append([
            TestOutput(["id": 1, "content": "a"]),
            TestOutput(["id": 2, "content": "b"]),
        ])

        app.get("foo") { req -> EventLoopFuture<[Post]> in
            req.fluent.history.start()
            return Post.query(on: req.db).all().map { posts in
                XCTAssertEqual(req.fluent.history.queries.count, 1)
                return posts
            }
        }

        try app.testable().test(.GET, "foo") { res in
            XCTAssertEqual(res.status, .ok)
        }
    }

    func testQueryHistoryEnableAndDisable() throws {
        let app = Application(.testing)
        defer { app.shutdown() }

        let test = ArrayTestDatabase()
        app.databases.use(test.configuration, as: .test)

        test.append([
            TestOutput(["id": 1, "content": "a"]),
            TestOutput(["id": 2, "content": "b"]),
        ])

        app.get("foo") { req -> EventLoopFuture<[Post]> in
            req.fluent.history.start()
            return Post.query(on: req.db).all().flatMap { posts -> EventLoopFuture<[Post]> in
                XCTAssertEqual(req.fluent.history.queries.count, 1)
                req.fluent.history.stop()

                test.append([
                    TestOutput(["id": 1, "content": "a"]),
                    TestOutput(["id": 2, "content": "b"]),
                ])

                return Post.query(on: req.db).all()
            }.map { posts in
                XCTAssertEqual(req.fluent.history.queries.count, 1)
                return posts
            }
        }

        try app.testable().test(.GET, "foo") { res in
            XCTAssertEqual(res.status, .ok)
        }
    }

    func testQueryHistoryForApp() throws {
        let app = Application(.testing)
        defer { app.shutdown() }

        app.fluent.history.start()
        let test = ArrayTestDatabase()
        app.databases.use(test.configuration, as: .test)

        test.append([
            TestOutput(["id": 1, "content": "a"]),
            TestOutput(["id": 2, "content": "b"]),
        ])

        _ = try Post.query(on: app.db).all().wait()

        test.append([
            TestOutput(["id": 1, "content": "a"]),
            TestOutput(["id": 2, "content": "b"]),
        ])

        _ = try Post.query(on: app.db).all().wait()

        test.append([
            TestOutput(["id": 1, "content": "a"]),
            TestOutput(["id": 2, "content": "b"]),
        ])

        app.fluent.history.stop()
        _ = try Post.query(on: app.db).all().wait()
        XCTAssertEqual(app.fluent.history.queries.count, 2)
    }
}

private final class Post: Model, Content, Equatable {
    static func == (lhs: Post, rhs: Post) -> Bool {
        lhs.id == rhs.id && lhs.content == rhs.content
    }

    static var schema: String { "posts" }

    @ID(custom: .id)
    var id: Int?

    @Field(key: "content")
    var content: String

    init() { }

    init(id: Int? = nil, content: String) {
        self.id = id
        self.content = content
    }
}
