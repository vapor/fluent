import Fluent
import FluentKit
import NIOConcurrencyHelpers
import Testing
import Vapor
import VaporTesting
import XCTFluent

@Suite
struct PaginationTests {
    @Test
    func pagination() async throws {
        try await withApp { app in
            let rows: NIOLockedValueBox<[TestOutput]> = .init([])
            rows.withLockedValue { $0 = (1...1_000).map { TestOutput(["id": $0, "title": "Todo #\($0)"]) } }

            let test = CallbackTestDatabase { query in
                #expect(query.schema == "todos")
                var result: [TestOutput] = []
                rows.withLockedValue {
                    if let limit = query.limits.first?.value, let offset = query.offsets.first?.value {
                        result = [TestOutput]($0[min(offset, $0.count - 1)..<min(offset + limit, $0.count)])
                    } else {
                        result = $0
                    }
                }

                return switch query.action {
                case .aggregate(_): [TestOutput([.aggregate: rows.withLockedValue { $0.count }])]
                default: result
                }
            }

            app.databases.use(test.configuration, as: .test)
            app.get("todos") { req -> Page<Todo> in
                try await Todo.query(on: req.db).paginate(for: req)
            }
            app.get("todos-elf") { req -> Page<Todo> in
                try await Todo.query(on: req.db).paginate(for: req).get()
            }

            try await app.test(.GET, "todos") { res async throws in
                #expect(res.status == .ok)
                let todos = try res.content.decode(Page<Todo>.self)
                #expect(todos.items[0].id == 1)
                #expect(todos.items.count == 10)
            }.test(.GET, "todos-elf") { res async throws in
                #expect(res.status == .ok)
                let todos = try res.content.decode(Page<Todo>.self)
                #expect(todos.items[0].id == 1)
                #expect(todos.items.count == 10)
            }.test(.GET, "todos-elf?page=invalid") { res async throws in
                #expect(res.status == .badRequest)
            }.test(.GET, "todos?page=2") { res async throws in
                #expect(res.status == .ok)
                let todos = try res.content.decode(Page<Todo>.self)
                #expect(todos.items[0].id == 11)
                #expect(todos.items.count == 10)
            }.test(.GET, "todos?page=2&per=15") { res async throws in
                #expect(res.status == .ok)
                let todos = try res.content.decode(Page<Todo>.self)
                #expect(todos.items[0].id == 16)
                #expect(todos.items.count == 15)
            }.test(.GET, "todos?page=1000&per=1") { res async throws in
                #expect(res.status == .ok)
                let todos = try res.content.decode(Page<Todo>.self)
                #expect(todos.items[0].id == 1000)
                #expect(todos.items.count == 1)
            }.test(.GET, "todos?page=1&per=1") { res async throws in
                #expect(res.status == .ok)
                let todos = try res.content.decode(Page<Todo>.self)
                #expect(todos.items[0].id == 1)
                #expect(todos.items.count == 1)
            }
        }
    }

    @Test
    func paginationLimits() async throws {
        try await withApp { app in
            let rows = [
                TestOutput(["id": 1, "title": "a"]),
                TestOutput(["id": 2, "title": "b"]),
                TestOutput(["id": 3, "title": "c"]),
                TestOutput(["id": 4, "title": "d"]),
                TestOutput(["id": 5, "title": "e"]),
            ]

            let test = CallbackTestDatabase { query in
                #expect(query.schema == "todos")
                let result: [TestOutput]
                if let limit = query.limits.first?.value, let offset = query.offsets.first?.value {
                    result = [TestOutput](rows[min(offset, rows.count - 1)..<min(offset + limit, rows.count)])
                } else {
                    result = rows
                }
                return switch query.action {
                case .aggregate(_): [TestOutput([.aggregate: rows.count])]
                default: result
                }
            }

            app.databases.use(test.configuration, as: .test)
            app.fluent.pagination.pageSizeLimit = 4

            app.get("todos-request-limit") { req -> Page<Todo> in
                req.fluent.pagination.pageSizeLimit = 2
                return try await Todo.query(on: req.db).paginate(for: req)
            }

            app.get("todos-request-no-limit") { req -> Page<Todo> in
                req.fluent.pagination.pageSizeLimit = .noLimit
                return try await Todo.query(on: req.db).paginate(for: req)
            }

            app.get("todos-request-app-limit") { req -> Page<Todo> in
                req.fluent.pagination.pageSizeLimit = nil
                return try await Todo.query(on: req.db).paginate(for: req)
            }

            app.get("todos-app-limit") { req -> Page<Todo> in
                try await Todo.query(on: req.db).paginate(for: req)
            }

            try await app.test(.GET, "todos-request-limit?page=1&per=5") { response async throws in
                #expect(response.status == .ok)
                let todos = try response.content.decode(Page<Todo>.self)
                #expect(todos.items.count == 2, "Should be capped by request-level limit.")
            }
            .test(.GET, "todos-request-no-limit?page=1&per=5") { response async throws in
                #expect(response.status == .ok)
                let todos = try response.content.decode(Page<Todo>.self)
                #expect(todos.items.count == 5, "Request-level override should suspend app-level limit.")
            }
            .test(.GET, "todos-request-app-limit?page=1&per=5") { response async throws in
                #expect(response.status == .ok)
                let todos = try response.content.decode(Page<Todo>.self)
                #expect(todos.items.count == 4, "Should be capped by app-level limit.")
            }
            .test(.GET, "todos-app-limit?page=1&per=5") { response async throws in
                #expect(response.status == .ok)
                let todos = try response.content.decode(Page<Todo>.self)
                #expect(todos.items.count == 4, "Should be capped by app-level limit.")
            }
        }
    }
}

extension DatabaseQuery.Limit {
    fileprivate var value: Int? {
        switch self {
        case .count(let count): count
        case .custom: nil
        }
    }
}

extension DatabaseQuery.Offset {
    fileprivate var value: Int? {
        switch self {
        case .count(let count): count
        case .custom: nil
        }
    }
}

private final class Todo: Model, Content, @unchecked Sendable {
    static let schema = "todos"

    @ID(custom: .id)
    var id: Int?

    @Field(key: "title")
    var title: String

    init() {}

    init(id: Int? = nil, title: String) {
        self.id = id
        self.title = title
    }
}
