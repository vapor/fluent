import Fluent
import NIO
import SQLite3

extension FluentFilter {
    public static func test(_ string: String) -> FluentFilter {
        return .custom(string)
    }
}

public struct TestDatabase: FluentDatabase {
    public var eventLoop: EventLoop
    
    private let sqlite: OpaquePointer
    
    public init(eventLoop: EventLoop) {
        self.eventLoop = eventLoop
        var ptr: OpaquePointer? = nil
        guard sqlite3_open(":memory:", &ptr) == SQLITE_OK, let sqlite = ptr else {
            fatalError("Could not open SQLite database")
        }
        self.sqlite = sqlite
    }
    
    public func fluentQuery(_ query: FluentQuery, _ onOutput: @escaping (FluentOutput) -> ()) -> EventLoopFuture<Void> {
        print(query)
        let sql: String
        switch query.action {
        case .read:
            var stmt = ["SELECT * FROM"]
            stmt += [query.entity]
            if !query.filters.isEmpty {
                stmt.append("WHERE")
                for filter in query.filters {
                    switch filter {
                    case .custom(let custom):
                        guard let custom = custom as? String else {
                            fatalError("custom not a string")
                        }
                        stmt += [custom]
                    case .basic(let field, let method, let value):
                        switch value {
                        case .bind(let enc):
                            stmt += ["\(field.path[0]) = '\(enc)'"]
                        case .array(let arr):
                            fatalError()
                        case .null:
                            stmt += ["\(field.path[0]) IS NULL"]
                        case .custom(let c):
                            fatalError()
                        }
                    case .group(let filters, let relation):
                        stmt += ["group!"]
                    }
                }
            }
            sql = stmt.joined(separator: " ")
        default: fatalError()
        }
        execute(sql: sql) {
            let test = TestOutput(eventLoop: eventLoop)
            onOutput(test)
        }
        return eventLoop.newSucceededFuture(result: ())
    }
    
    public func execute(sql: String, onRow: () -> () = {}) {
        print("[TestDatabase] \(sql)")
        var stmt: OpaquePointer? = nil
        guard sqlite3_prepare_v2(sqlite, sql, -1, &stmt, nil) == SQLITE_OK else {
            fatalError("Could not prepare statement")
        }
        
        while sqlite3_step(stmt) != SQLITE_DONE {
            onRow()
        }
        sqlite3_finalize(stmt)
    }
}

struct TestOutput: FluentOutput {
    var eventLoop: EventLoop
    
    init(eventLoop: EventLoop) {
        self.eventLoop = eventLoop
    }
    
    func fluentDecode<T>(_ type: T.Type, entity: String?) -> EventLoopFuture<T> where T : Decodable {
        do {
            let dummy = try T(from: DummyDecoder())
            return self.eventLoop.newSucceededFuture(result: dummy)
        } catch {
            return self.eventLoop.newFailedFuture(error: error)
        }
    }
}
