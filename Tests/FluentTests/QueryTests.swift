import XCTest
@testable import Fluent

class QueryTests: XCTestCase {
    static let allTests = [
        ("testFirst", testFirst),
        ("testFirstComputedFields", testFirstComputedFields),
        ("testAll", testAll),
        ("testAllComputedFields", testAllComputedFields),
        ("testFind", testFind),
        ("testFindComputedFields", testFindComputedFields)
    ]
    
    var lqd: LastQueryDriver!
    var db: Database!
    
    override func setUp() {
        lqd = LastQueryDriver()
        db = Database(lqd)
        
        Atom.database = db
    }
    
    func testFirst() throws {
        do {
            _ = try Atom.makeQuery().first()
        } catch {
            // pass
        }
        
        if let (sql, _) = lqd.lastQuery {
            XCTAssertEqual(sql, "SELECT `atoms`.* FROM `atoms` LIMIT 0, 1")
        } else {
            XCTFail("No last query.")
        }
    }
    
    func testFirstComputedFields() throws {
        do {
            _ = try Atom.makeQuery().first([RawOr.raw("true AS computed", [])])
        } catch {
            // pass
        }
        
        if let (sql, _) = lqd.lastQuery {
            XCTAssertEqual(sql, "SELECT `atoms`.*, true AS computed FROM `atoms` LIMIT 0, 1")
        } else {
            XCTFail("No last query.")
        }
    }
    
    func testAll() throws {
        do {
            _ = try Atom.makeQuery().all()
        } catch {
            // pass
        }
        
        if let (sql, _) = lqd.lastQuery {
            XCTAssertEqual(sql, "SELECT `atoms`.* FROM `atoms`")
        } else {
            XCTFail("No last query.")
        }
    }
    
    func testAllComputedFields() throws {
        do {
            _ = try Atom.makeQuery().all([RawOr.raw("true AS computed", [])])
        } catch {
            // pass
        }
        
        if let (sql, _) = lqd.lastQuery {
            XCTAssertEqual(sql, "SELECT `atoms`.*, true AS computed FROM `atoms`")
        } else {
            XCTFail("No last query.")
        }
    }
    
    func testFind() {
        do {
            _ = try Atom.makeQuery().find(1)
        } catch {
            // pass
        }
        
        if let (sql, _) = lqd.lastQuery {
            XCTAssertEqual(sql, "SELECT `atoms`.* FROM `atoms` WHERE `atoms`.`#id` = ? LIMIT 0, 1")
        } else {
            XCTFail("No last query.")
        }
    }
    
    func testFindComputedFields() {
        do {
            _ = try Atom.makeQuery().find(1, [RawOr.raw("true AS computed", [])])
        } catch {
            // pass
        }
        
        if let (sql, _) = lqd.lastQuery {
            XCTAssertEqual(sql, "SELECT `atoms`.*, true AS computed FROM `atoms` WHERE `atoms`.`#id` = ? LIMIT 0, 1")
        } else {
            XCTFail("No last query.")
        }
    }
}
