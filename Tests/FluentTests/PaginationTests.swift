import Fluent
import Vapor
import XCTVapor
import XCTFluent

final class PaginationTests: XCTestCase {
    func testPagination() throws {
        let app = Application(.testing)
        defer { app.shutdown() }

        let test = TestDatabase()
        app.databases.use(test.configuration, as: .test)

        app.get("todos") { req -> EventLoopFuture<Page<Todo>> in
            Todo.query(on: req.db).paginate(for: req)
        }

        var rows: [TestOutput] = []
        for i in 1...1_000 {
            rows.append(TestOutput([
                "id": i,
                "title": "Todo #\(i)"
            ]))
        }
        
        test.use { query in
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

