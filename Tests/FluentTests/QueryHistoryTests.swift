import Fluent
import Vapor
import XCTFluent
import XCTVapor

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
                XCTAssertEqual(req.queryHistory.queries.count, 0)
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

        app.fluent.enableQueryHistory()
        let test = ArrayTestDatabase()
        app.databases.use(test.configuration, as: .test)

        test.append([
            TestOutput(["id": 1, "content": "a"]),
            TestOutput(["id": 2, "content": "b"]),
        ])

        app.get("foo") { req -> EventLoopFuture<[Post]> in
            return Post.query(on: req.db).all().map { posts in
                XCTAssertEqual(req.queryHistory.queries.count, 1)
                return posts
            }
        }

        try app.testable().test(.GET, "foo") { res in
            XCTAssertEqual(res.status, .ok)
        }
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
