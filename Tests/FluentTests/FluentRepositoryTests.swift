import Fluent
import Vapor
import XCTVapor

final class FluentRepositoryTests: XCTestCase {
    func testRepositoryPatternStatic() throws {
        let app = Application(.testing)
        defer { app.shutdown() }

        var posts: [Post] = [
            .init(content: "a"),
            .init(content: "b")
        ]

        app.posts.use {
            TestPostRepository(posts: posts, eventLoop: $0.eventLoop)
        }

        app.get("foo") { req -> EventLoopFuture<[Post]> in
            req.posts.all()
        }

        try app.testable().test(.GET, "foo") { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqualJSON(res.body.string, posts)
        }

        posts.append(.init(content: "c"))

        try app.testable().test(.GET, "foo") { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqualJSON(res.body.string, posts)
        }
    }
    
    func testRepositoryPatternDatabase() throws {
        let app = Application(.testing)
        defer { app.shutdown() }

        app.databases.use(TestDatabaseDriver { query in
            XCTAssertEqual(query.schema, "posts")
            return [
                TestRow(data: ["id": 1, "content": "a"]),
                TestRow(data: ["id": 2, "content": "b"]),
            ]
        }, as: .test)
        
        app.posts.use { req in
            DatabasePostRepository(database: req.db(.test))
        }
        
        app.get("foo") { req -> EventLoopFuture<[Post]> in
            req.posts.all()
        }
        
        let posts: [Post] = [
            .init(id: 1, content: "a"),
            .init(id: 2, content: "b")
        ]
        
        try app.testable().test(.GET, "foo") { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqualJSON(res.body.string, posts)
        }
    }
}

private extension Request {
    var posts: PostRepository {
        self.application.posts.makePosts!(self)
    }
}

private extension Application {
    var posts: PostRepositoryFactory {
        get {
            if let existing = self.userInfo["posts"] as? PostRepositoryFactory {
                return existing
            } else {
                let new = PostRepositoryFactory()
                self.userInfo["posts"] = new
                return new
            }
        }
        set {
            self.userInfo["posts"] = newValue
        }
    }
}

private struct PostRepositoryFactory {
    var makePosts: ((Request) -> PostRepository)?
    mutating func use(_ makePosts: @escaping (Request) -> PostRepository) {
        self.makePosts = makePosts
    }
}

private final class Post: Model, Content, Equatable {
    static func == (lhs: Post, rhs: Post) -> Bool {
        lhs.id == rhs.id && lhs.content == rhs.content
    }
    
    static var schema: String { "posts" }
    
    @ID(key: "id")
    var id: Int?
    
    @Field(key: "content")
    var content: String
    
    init() { }
    
    init(id: Int? = nil, content: String) {
        self.id = id
        self.content = content
    }
}

private struct TestPostRepository: PostRepository {
    let posts: [Post]
    let eventLoop: EventLoop

    func all() -> EventLoopFuture<[Post]> {
        self.eventLoop.makeSucceededFuture(self.posts)
    }
}

private struct DatabasePostRepository: PostRepository {
    let database: Database
    func all() -> EventLoopFuture<[Post]> {
        database.query(Post.self).all()
    }
}

private protocol PostRepository {
    func all() -> EventLoopFuture<[Post]>
}
