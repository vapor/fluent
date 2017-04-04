import XCTest
@testable import Fluent

class JoinTests: XCTestCase {
    static let allTests = [
        ("testBasic", testBasic),
        ("testSQLFilters", testSQLFilters),
        ("testSiblings", testSiblings)
    ]

    var lqd: LastQueryDriver!
    var db: Database!

    override func setUp() {
        lqd = LastQueryDriver()
        db = Database(lqd)
        
        Atom.database = db
        Compound.database = db
        CustomIdKey.database = db
    }

    func testBasic() throws {
        let query = try Query<Atom>(db).join(Compound.self)
        try lqd.query(query)

        if let (sql, _) = lqd.lastQuery {
            XCTAssertEqual(sql, "SELECT `atoms`.* FROM `atoms` JOIN `compounds` ON `atoms`.`#id` = `compounds`.`atom_#id`")
        } else {
            XCTFail("No last query.")
        }
    }

    func testSQLFilters() throws {
        let query = try Query<Atom>(db)
            .join(Compound.self)
            .filter("protons", .greaterThan, 5)
            .filter(Compound.self, "atoms", .lessThan, 128)

        try lqd.query(query)

        if let (sql, values) = lqd.lastQuery {
            XCTAssertEqual(sql, "SELECT `atoms`.* FROM `atoms` JOIN `compounds` ON `atoms`.`#id` = `compounds`.`atom_#id` WHERE `atoms`.`protons` > ? AND `compounds`.`atoms` < ?")
            if values.count == 2 {
                XCTAssertEqual(values[0].int, 5)
                XCTAssertEqual(values[1].int, 128)
            } else {
                XCTFail("Invalid values count")
            }
        } else {
            XCTFail("No last query.")
        }
    }


    func testSiblings() throws {
        let atom = Atom(name: "Hydrogen")
        atom.id = 42

        do {
            _ = try atom.compounds.all()
        } catch {
            // pass
        }

        if let (sql, values) = lqd.lastQuery {
            XCTAssertEqual(
                sql,
                "SELECT `compounds`.* FROM `compounds` JOIN `atom_compound` ON `compounds`.`#id` = `atom_compound`.`compound_#id` WHERE `atom_compound`.`atom_#id` = ?"
            )
            XCTAssertEqual(values.count, 1)
            XCTAssertEqual(values.first?.int, 42)
        }
    }
}
