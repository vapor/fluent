import Fluent
import Vapor
import XCTFluent
import XCTVapor
import FluentKit

final class RepositoryTests: XCTestCase {
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

        let test = ArrayTestDatabase()
        app.databases.use(test.configuration, as: .test)
        
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

        test.append([
            TestOutput(["id": 1, "content": "a"]),
            TestOutput(["id": 2, "content": "b"]),
        ])
        
        try app.testable().test(.GET, "foo") { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqualJSON(res.body.string, posts)
        }
    }
}

extension ByteBuffer {
    var string: String {
        .init(decoding: self.readableBytesView, as: UTF8.self)
    }
}

private extension Request {
    var posts: any PostRepository {
        self.application.posts.makePosts!(self)
    }
}

private extension Application {
    private struct PostRepositoryKey: StorageKey {
        typealias Value = PostRepositoryFactory
    }
    var posts: PostRepositoryFactory {
        get {
            self.storage[PostRepositoryKey.self] ?? .init()
        }
        set {
            self.storage[PostRepositoryKey.self] = newValue
        }
    }
}

private struct PostRepositoryFactory: @unchecked Sendable { // not actually Sendable but the compiler doesn't need to know that
    var makePosts: ((Request) -> any PostRepository)?
    mutating func use(_ makePosts: @escaping (Request) -> any PostRepository) {
        self.makePosts = makePosts
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

private struct TestPostRepository: PostRepository {
    let posts: [Post]
    let eventLoop: any EventLoop

    func all() -> EventLoopFuture<[Post]> {
        self.eventLoop.makeSucceededFuture(self.posts)
    }
}

private struct DatabasePostRepository: PostRepository {
    let database: any Database
    func all() -> EventLoopFuture<[Post]> {
        database.query(Post.self).all()
    }
}

private protocol PostRepository {
    func all() -> EventLoopFuture<[Post]>
}
