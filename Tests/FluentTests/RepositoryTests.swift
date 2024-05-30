import Fluent
import Vapor
import XCTFluent
import XCTVapor
import FluentKit
import NIOConcurrencyHelpers

final class RepositoryTests: XCTestCase {
    var app: Application!
    
    override func setUp() async throws {
        self.app = try await Application.make(.testing)
    }
    
    override func tearDown() async throws {
        try await self.app.asyncShutdown()
        self.app = nil
    }
    
    func testRepositoryPatternStatic() async throws {
        let posts: NIOLockedValueBox<[Post]> = .init([
            .init(content: "a"),
            .init(content: "b")
        ])

        self.app.posts.use {
            TestPostRepository(posts: posts.withLockedValue { $0 }, eventLoop: $0.eventLoop)
        }

        self.app.get("foo") { req -> [Post] in
            try await req.posts.all()
        }

        try await self.app.testable().test(.GET, "foo") { res async in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqualJSON(res.body.string, posts.withLockedValue { $0 })
        }

        posts.withLockedValue { $0.append(.init(content: "c")) }

        try await self.app.testable().test(.GET, "foo") { res async in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqualJSON(res.body.string, posts.withLockedValue { $0 })
        }
    }
    
    func testRepositoryPatternDatabase() async throws {
        let test = ArrayTestDatabase()
        self.app.databases.use(test.configuration, as: .test)
        
        self.app.posts.use { req in
            DatabasePostRepository(database: req.db(.test))
        }
        
        self.app.get("foo") { req -> [Post] in
            try await req.posts.all()
        }
        
        let posts: [Post] = [
            .init(id: 1, content: "a"),
            .init(id: 2, content: "b")
        ]

        test.append([
            TestOutput(["id": 1, "content": "a"]),
            TestOutput(["id": 2, "content": "b"]),
        ])
        
        try await self.app.testable().test(.GET, "foo") { res async in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqualJSON(res.body.string, posts)
        }
    }
}

extension ByteBuffer {
    var string: String {
        self.getString(at: self.readerIndex, length: self.readableBytes)!
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
        get { self.storage[PostRepositoryKey.self] ?? .init() }
        set { self.storage[PostRepositoryKey.self] = newValue }
    }
}

private struct PostRepositoryFactory: @unchecked Sendable { // not actually Sendable but the compiler doesn't need to know that
    var makePosts: (@Sendable (Request) -> any PostRepository)?
    
    mutating func use(_ makePosts: @escaping @Sendable (Request) -> any PostRepository) {
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

    func all() -> EventLoopFuture<[Post]> { self.eventLoop.makeSucceededFuture(self.posts) }
    func all() async throws -> [Post] { self.posts }
}

private struct DatabasePostRepository: PostRepository {
    let database: any Database
    
    func all() -> EventLoopFuture<[Post]> { self.database.query(Post.self).all() }
    func all() async throws -> [Post] { try await self.database.query(Post.self).all() }
}

private protocol PostRepository {
    func all() -> EventLoopFuture<[Post]>
    func all() async throws -> [Post]
}
