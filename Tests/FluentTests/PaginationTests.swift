import Fluent
import Vapor
import XCTVapor
import XCTFluent
import FluentKit
import NIOConcurrencyHelpers

final class PaginationTests: XCTestCase {
    var app: Application!
    
    override func setUp() async throws {
        self.app = try await Application.make(.testing)
    }
    
    override func tearDown() async throws {
        try await self.app.asyncShutdown()
        self.app = nil
    }
    
    func testPagination() async throws {
        let rows: NIOLockedValueBox<[TestOutput]> = .init([])
        for i in 1...1_000 {
            rows.withLockedValue { $0.append(TestOutput([
                "id": i,
                "title": "Todo #\(i)"
            ])) }
        }
        let test = CallbackTestDatabase { query in
            XCTAssertEqual(query.schema, "todos")
            var result: [TestOutput] = []
            rows.withLockedValue {
                if let limit = query.limits.first?.value, let offset = query.offsets.first?.value {
                    result = [TestOutput]($0[min(offset, $0.count - 1)..<min(offset + limit, $0.count)])
                } else {
                    result = $0
                }
            }

            switch query.action {
            case .aggregate(_):
                return [TestOutput([.aggregate: rows.withLockedValue { $0.count }])]
            default:
                return result
            }
        }

        self.app.databases.use(test.configuration, as: .test)
        self.app.get("todos") { req -> Page<Todo> in
            try await Todo.query(on: req.db).paginate(for: req)
        }
        self.app.get("todos-elf") { req -> Page<Todo> in
            try await Todo.query(on: req.db).paginate(for: req).get()
        }

        try await self.app.test(.GET, "todos") { res async throws in
            XCTAssertEqual(res.status, .ok)
            let todos = try res.content.decode(Page<Todo>.self)
            XCTAssertEqual(todos.items[0].id, 1)
            XCTAssertEqual(todos.items.count, 10)
        }.test(.GET, "todos-elf") { res async throws in
            XCTAssertEqual(res.status, .ok)
            let todos = try res.content.decode(Page<Todo>.self)
            XCTAssertEqual(todos.items[0].id, 1)
            XCTAssertEqual(todos.items.count, 10)
        }.test(.GET, "todos-elf?page=invalid") { res async throws in
            XCTAssertEqual(res.status, .badRequest)
        }.test(.GET, "todos?page=2") { res async throws in
            XCTAssertEqual(res.status, .ok)
            let todos = try res.content.decode(Page<Todo>.self)
            XCTAssertEqual(todos.items[0].id, 11)
            XCTAssertEqual(todos.items.count, 10)
        }.test(.GET, "todos?page=2&per=15") { res async throws in
            XCTAssertEqual(res.status, .ok)
            let todos = try res.content.decode(Page<Todo>.self)
            XCTAssertEqual(todos.items[0].id, 16)
            XCTAssertEqual(todos.items.count, 15)
        }.test(.GET, "todos?page=1000&per=1") { res async throws in
            XCTAssertEqual(res.status, .ok)
            let todos = try res.content.decode(Page<Todo>.self)
            XCTAssertEqual(todos.items[0].id, 1000)
            XCTAssertEqual(todos.items.count, 1)
        }.test(.GET, "todos?page=1&per=1") { res async throws in
            XCTAssertEqual(res.status, .ok)
            let todos = try res.content.decode(Page<Todo>.self)
            XCTAssertEqual(todos.items[0].id, 1)
            XCTAssertEqual(todos.items.count, 1)
        }
    }

    func testPaginationLimits() async throws {
        let rows = [
            TestOutput(["id": 1, "title": "a"]),
            TestOutput(["id": 2, "title": "b"]),
            TestOutput(["id": 3, "title": "c"]),
            TestOutput(["id": 4, "title": "d"]),
            TestOutput(["id": 5, "title": "e"]),
        ]

        let test = CallbackTestDatabase { query in
            XCTAssertEqual(query.schema, "todos")
            let result: [TestOutput]
            if let limit = query.limits.first?.value, let offset = query.offsets.first?.value {
                result = [TestOutput](rows[min(offset, rows.count - 1)..<min(offset + limit, rows.count)])
            } else {
                result = rows
            }
            switch query.action {
            case .aggregate(_):
                return [TestOutput([.aggregate: rows.count])]
            default:
                return result
            }
        }

        self.app.databases.use(test.configuration, as: .test)
        self.app.fluent.pagination.pageSizeLimit = 4

        self.app.get("todos-request-limit") { req -> Page<Todo> in
            req.fluent.pagination.pageSizeLimit = 2
            return try await Todo.query(on: req.db).paginate(for: req)
        }

        self.app.get("todos-request-no-limit") { req -> Page<Todo> in
            req.fluent.pagination.pageSizeLimit = .noLimit
            return try await Todo.query(on: req.db).paginate(for: req)
        }

        self.app.get("todos-request-app-limit") { req -> Page<Todo> in
            req.fluent.pagination.pageSizeLimit = nil
            return try await Todo.query(on: req.db).paginate(for: req)
        }

        self.app.get("todos-app-limit") { req -> Page<Todo> in
            try await Todo.query(on: req.db).paginate(for: req)
        }

        try await self.app.test(.GET, "todos-request-limit?page=1&per=5") { response async throws in
            XCTAssertEqual(response.status, .ok)
            let todos = try response.content.decode(Page<Todo>.self)
            XCTAssertEqual(todos.items.count, 2, "Should be capped by request-level limit.")
        }
        .test(.GET, "todos-request-no-limit?page=1&per=5") { response async throws in
            XCTAssertEqual(response.status, .ok)
            let todos = try response.content.decode(Page<Todo>.self)
            XCTAssertEqual(todos.items.count, 5, "Request-level override should suspend app-level limit.")
        }
        .test(.GET, "todos-request-app-limit?page=1&per=5") { response async throws in
            XCTAssertEqual(response.status, .ok)
            let todos = try response.content.decode(Page<Todo>.self)
            XCTAssertEqual(todos.items.count, 4, "Should be capped by app-level limit.")
        }
        .test(.GET, "todos-app-limit?page=1&per=5") { response async throws in
            XCTAssertEqual(response.status, .ok)
            let todos = try response.content.decode(Page<Todo>.self)
            XCTAssertEqual(todos.items.count, 4, "Should be capped by app-level limit.")
        }
    }
}

private extension DatabaseQuery.Limit {
    var value: Int? {
        switch self {
        case .count(let count):
            return count
        case .custom:
            return nil
        }
    }
}

private extension DatabaseQuery.Offset {
    var value: Int? {
        switch self {
        case .count(let count):
            return count
        case .custom:
            return nil
        }
    }
}

private final class Todo: Model, Content, @unchecked Sendable {
    static let schema = "todos"

    @ID(custom: .id)
    var id: Int?

    @Field(key: "title")
    var title: String

    init() { }

    init(id: Int? = nil, title: String) {
        self.id = id
        self.title = title
    }
}

