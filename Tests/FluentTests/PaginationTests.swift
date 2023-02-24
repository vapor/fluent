import Fluent
import Vapor
import XCTVapor
import XCTFluent
import FluentKit

final class PaginationTests: XCTestCase {
    func testPagination() throws {
        let app = Application(.testing)
        defer { app.shutdown() }

        var rows: [TestOutput] = []
        for i in 1...1_000 {
            rows.append(TestOutput([
                "id": i,
                "title": "Todo #\(i)"
            ]))
        }
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
        app.databases.use(test.configuration, as: .test)

        app.get("todos") { req -> EventLoopFuture<Page<Todo>> in
            Todo.query(on: req.db).paginate(for: req)
        }

        try app.test(.GET, "todos") { res in
            XCTAssertEqual(res.status, .ok)
            let todos = try res.content.decode(Page<Todo>.self)
            XCTAssertEqual(todos.items[0].id, 1)
            XCTAssertEqual(todos.items.count, 10)
        }.test(.GET, "todos?page=2") { res in
            XCTAssertEqual(res.status, .ok)
            let todos = try res.content.decode(Page<Todo>.self)
            XCTAssertEqual(todos.items[0].id, 11)
            XCTAssertEqual(todos.items.count, 10)
        }.test(.GET, "todos?page=2&per=15") { res in
            XCTAssertEqual(res.status, .ok)
            let todos = try res.content.decode(Page<Todo>.self)
            XCTAssertEqual(todos.items[0].id, 16)
            XCTAssertEqual(todos.items.count, 15)
        }.test(.GET, "todos?page=1000&per=1") { res in
            XCTAssertEqual(res.status, .ok)
            let todos = try res.content.decode(Page<Todo>.self)
            XCTAssertEqual(todos.items[0].id, 1000)
            XCTAssertEqual(todos.items.count, 1)
        }.test(.GET, "todos?page=1&per=1") { res in
            XCTAssertEqual(res.status, .ok)
            let todos = try res.content.decode(Page<Todo>.self)
            XCTAssertEqual(todos.items[0].id, 1)
            XCTAssertEqual(todos.items.count, 1)
        }
    }

    func testPaginationLimits() throws {
        let app = Application(.testing)
        defer { app.shutdown() }

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

        app.databases.use(test.configuration, as: .test)
        app.fluent.pagination.pageSizeLimit = 4

        app.get("todos-request-limit") { req -> EventLoopFuture<Page<Todo>> in
            req.fluent.pagination.pageSizeLimit = 2
            return Todo.query(on: req.db).paginate(for: req)
        }

        app.get("todos-request-no-limit") { req -> EventLoopFuture<Page<Todo>> in
            req.fluent.pagination.pageSizeLimit = .noLimit
            return Todo.query(on: req.db).paginate(for: req)
        }

        app.get("todos-request-app-limit") { req -> EventLoopFuture<Page<Todo>> in
            req.fluent.pagination.pageSizeLimit = nil
            return Todo.query(on: req.db).paginate(for: req)
        }

        app.get("todos-app-limit") { req -> EventLoopFuture<Page<Todo>> in
            Todo.query(on: req.db).paginate(for: req)
        }

        try app.test(.GET, "todos-request-limit?page=1&per=5") { response in
            XCTAssertEqual(response.status, .ok)
            let todos = try response.content.decode(Page<Todo>.self)
            XCTAssertEqual(todos.items.count, 2, "Should be capped by request-level limit.")
        }
        .test(.GET, "todos-request-no-limit?page=1&per=5") { response in
            XCTAssertEqual(response.status, .ok)
            let todos = try response.content.decode(Page<Todo>.self)
            XCTAssertEqual(todos.items.count, 5, "Request-level override should suspend app-level limit.")
        }
        .test(.GET, "todos-request-app-limit?page=1&per=5") { response in
            XCTAssertEqual(response.status, .ok)
            let todos = try response.content.decode(Page<Todo>.self)
            XCTAssertEqual(todos.items.count, 4, "Should be capped by app-level limit.")
        }
        .test(.GET, "todos-app-limit?page=1&per=5") { response in
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

private final class Todo: Model, Content {
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

