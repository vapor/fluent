import Async
@testable import Fluent
import FluentBenchmark
import FluentSQL
import DatabaseKit
import XCTest
import Core

final class QueryBuilderTests: XCTestCase {
    
    var query: QueryBuilder<Snowman, Snowman>!
    
    override func setUp() {
        query = Snowman.query(on: FakeDatabaseConnectable())
    }
    
    func testBasicQuery() throws {
        let (sqlQuery, _) = query.query.makeDataQuery()
        let sqlString = FakeSQLSerializer().serialize(data: sqlQuery)
        
        XCTAssertEqual(sqlString, "SELECT * FROM `snowmans`")
    }
    
    func testCustomFieldsBasicQuery() throws {
        query = try query.fields([\Snowman.name])
        
        let (sqlQuery, _) = query.query.makeDataQuery()
        let sqlString = FakeSQLSerializer().serialize(data: sqlQuery)
        
        XCTAssertEqual(sqlString, "SELECT `snowmans`.`name` FROM `snowmans`")
    }
    
    static let allTests = [
        ("testBasicQuery", testBasicQuery),
        ("testCustomFieldsBasicQuery", testCustomFieldsBasicQuery)
        ]
}


