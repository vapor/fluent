import Fluent
import Vapor
import XCTFluent
import XCTVapor
import FluentKit

final class QueryHistoryTests: XCTestCase {
    var app: Application!
    
    override func setUp() async throws {
        self.app = try await Application.make(.testing)
    }
    
    override func tearDown() async throws {
        try await self.app.asyncShutdown()
        self.app = nil
    }
    
    func testQueryHistoryDisabled() async throws {
        let test = ArrayTestDatabase()
        self.app.databases.use(test.configuration, as: .test)

        test.append([
            TestOutput(["id": 1, "content": "a"]),
            TestOutput(["id": 2, "content": "b"]),
        ])

        self.app.get("foo") { req -> [Post] in
            let posts = try await Post.query(on: req.db).all()
            XCTAssertEqual(req.fluent.history.queries.count, 0)
            return posts
        }

        try await self.app.testable().test(.GET, "foo") { res async in
            XCTAssertEqual(res.status, .ok)
        }
    }

    func testQueryHistoryEnabled() async throws {
        let test = ArrayTestDatabase()
        self.app.databases.use(test.configuration, as: .test)

        test.append([
            TestOutput(["id": 1, "content": "a"]),
            TestOutput(["id": 2, "content": "b"]),
        ])

        self.app.get("foo") { req -> [Post] in
            req.fluent.history.start()
            let posts = try await Post.query(on: req.db).all()
            XCTAssertEqual(req.fluent.history.queries.count, 1)
            return posts
        }

        try await self.app.testable().test(.GET, "foo") { res async in
            XCTAssertEqual(res.status, .ok)
        }
    }

    func testQueryHistoryEnableAndDisable() async throws {
        let test = ArrayTestDatabase()
        self.app.databases.use(test.configuration, as: .test)

        test.append([
            TestOutput(["id": 1, "content": "a"]),
            TestOutput(["id": 2, "content": "b"]),
        ])
        test.append([
            TestOutput(["id": 1, "content": "a"]),
            TestOutput(["id": 2, "content": "b"]),
        ])

        self.app.get("foo") { req -> [Post] in
            req.fluent.history.start()
            _ = try await Post.query(on: req.db).all()
            XCTAssertEqual(req.fluent.history.queries.count, 1)
            req.fluent.history.stop()

            let posts = try await Post.query(on: req.db).all()
            XCTAssertEqual(req.fluent.history.queries.count, 1)
            return posts
        }

        try await self.app.testable().test(.GET, "foo") { res async in
            XCTAssertEqual(res.status, .ok)
        }
    }

    func testQueryHistoryForApp() async throws {
        self.app.fluent.history.start()
        let test = ArrayTestDatabase()
        self.app.databases.use(test.configuration, as: .test)

        test.append([
            TestOutput(["id": 1, "content": "a"]),
            TestOutput(["id": 2, "content": "b"]),
        ])

        _ = try await Post.query(on: self.app.db).all()

        test.append([
            TestOutput(["id": 1, "content": "a"]),
            TestOutput(["id": 2, "content": "b"]),
        ])

        _ = try await Post.query(on: self.app.db).all()

        test.append([
            TestOutput(["id": 1, "content": "a"]),
            TestOutput(["id": 2, "content": "b"]),
        ])

        self.app.fluent.history.stop()
        _ = try await Post.query(on: self.app.db).all()
        XCTAssertEqual(self.app.fluent.history.queries.count, 2)
    }
}

private final class Post: Model, Content, Equatable, @unchecked Sendable {
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
