import XCTest
@testable import Fluent

extension Atom: Timestampable { }
extension Atom: Paginatable { }

class PaginatableTests: XCTestCase {
    static let allTests = [
        ("testPaginate", testPaginate),
        ("testPaginateOffset", testPaginateOffset),
        ("testPaginateSize", testPaginateSize),
        ("testPaginateSorts", testPaginateSorts),
        ("testPaginateComputedFields", testPaginateComputedFields)
    ]
    
    var lqd: LastQueryDriver!
    var db: Database!
    
    override func setUp() {
        lqd = LastQueryDriver()
        db = Database(lqd)
        
        Atom.database = db
    }
    
    func testPaginate() throws {
        do {
            _ = try Atom.makeQuery().paginate(page: 1)
        } catch {
            // pass
        }
        
        if let (sql, _) = lqd.lastQuery {
            XCTAssertEqual(sql, "SELECT `atoms`.* FROM `atoms` ORDER BY `atoms`.`created_at` DESC LIMIT 0, 10")
        } else {
            XCTFail("No last query.")
        }
    }
    
    func testPaginateOffset() {
        do {
            _ = try Atom.makeQuery().paginate(page: 3)
        } catch {
            // pass
        }
        
        if let (sql, _) = lqd.lastQuery {
            XCTAssertEqual(sql, "SELECT `atoms`.* FROM `atoms` ORDER BY `atoms`.`created_at` DESC LIMIT 20, 10")
        } else {
            XCTFail("No last query.")
        }
    }
    
    func testPaginateSize() {
        do {
            _ = try Atom.makeQuery().paginate(page: 1, count: 30)
        } catch {
            // pass
        }
        
        if let (sql, _) = lqd.lastQuery {
            XCTAssertEqual(sql, "SELECT `atoms`.* FROM `atoms` ORDER BY `atoms`.`created_at` DESC LIMIT 0, 30")
        } else {
            XCTFail("No last query.")
        }
    }
    
    func testPaginateSorts() {
        do {
            _ = try Atom.makeQuery().paginate(page: 1, [Sort.init(Atom.self, Atom.idKey, .ascending)])
        } catch {
            // pass
        }
        
        if let (sql, _) = lqd.lastQuery {
            XCTAssertEqual(sql, "SELECT `atoms`.* FROM `atoms` ORDER BY `atoms`.`#id` ASC LIMIT 0, 10")
        } else {
            XCTFail("No last query.")
        }
    }
    
    func testPaginateComputedFields() {
        do {
            _ = try Atom.makeQuery().paginate(page: 1, computedFields: [RawOr.raw("true AS computed", [])])
        } catch {
            // pass
        }
        
        if let (sql, _) = lqd.lastQuery {
            XCTAssertEqual(sql, "SELECT `atoms`.*, true AS computed FROM `atoms` ORDER BY `atoms`.`created_at` DESC LIMIT 0, 10")
        } else {
            XCTFail("No last query.")
        }
    }
}
