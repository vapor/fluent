import Fluent
import Testing
import Vapor
import VaporTesting
import XCTFluent

@Suite
struct QueryHistoryTests {
    @Test
    func queryHistoryDisabled() async throws {
        try await withApp { app in
            let test = ArrayTestDatabase()
            app.databases.use(test.configuration, as: .test)

            test.append([
                TestOutput(["id": 1, "content": "a"]),
                TestOutput(["id": 2, "content": "b"]),
            ])

            app.get("foo") { req -> [Post] in
                let posts = try await Post.query(on: req.db).all()
                #expect(req.fluent.history.queries.count == 0)
                return posts
            }

            try await app.test(.GET, "foo") { res async in
                #expect(res.status == .ok)
            }
        }
    }

    @Test
    func queryHistoryEnabled() async throws {
        try await withApp { app in
            let test = ArrayTestDatabase()
            app.databases.use(test.configuration, as: .test)

            test.append([
                TestOutput(["id": 1, "content": "a"]),
                TestOutput(["id": 2, "content": "b"]),
            ])

            app.get("foo") { req -> [Post] in
                req.fluent.history.start()
                let posts = try await Post.query(on: req.db).all()
                #expect(req.fluent.history.queries.count == 1)
                return posts
            }

            try await app.test(.GET, "foo") { res async in
                #expect(res.status == .ok)
            }
        }
    }

    @Test
    func queryHistoryEnableAndDisable() async throws {
        try await withApp { app in
            let test = ArrayTestDatabase()
            app.databases.use(test.configuration, as: .test)

            test.append([
                TestOutput(["id": 1, "content": "a"]),
                TestOutput(["id": 2, "content": "b"]),
            ])
            test.append([
                TestOutput(["id": 1, "content": "a"]),
                TestOutput(["id": 2, "content": "b"]),
            ])

            app.get("foo") { req -> [Post] in
                req.fluent.history.start()
                _ = try await Post.query(on: req.db).all()
                #expect(req.fluent.history.queries.count == 1)
                req.fluent.history.stop()

                let posts = try await Post.query(on: req.db).all()
                #expect(req.fluent.history.queries.count == 1)
                return posts
            }

            try await app.test(.GET, "foo") { res async in
                #expect(res.status == .ok)
            }
        }
    }

    @Test
    func queryHistoryForApp() async throws {
        try await withApp { app in
            app.fluent.history.start()
            let test = ArrayTestDatabase()
            app.databases.use(test.configuration, as: .test)

            test.append([
                TestOutput(["id": 1, "content": "a"]),
                TestOutput(["id": 2, "content": "b"]),
            ])

            _ = try await Post.query(on: app.db).all()

            test.append([
                TestOutput(["id": 1, "content": "a"]),
                TestOutput(["id": 2, "content": "b"]),
            ])

            _ = try await Post.query(on: app.db).all()

            test.append([
                TestOutput(["id": 1, "content": "a"]),
                TestOutput(["id": 2, "content": "b"]),
            ])

            app.fluent.history.stop()
            _ = try await Post.query(on: app.db).all()
            #expect(app.fluent.history.queries.count == 2)
        }
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

    init() {}

    init(id: Int? = nil, content: String) {
        self.id = id
        self.content = content
    }
}
