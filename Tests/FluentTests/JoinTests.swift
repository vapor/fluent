import XCTest
@testable import Fluent

class JoinTests: XCTestCase {
    static let allTests = [
        ("testBasic", testBasic),
        ("testCustom", testCustom),
        ("testSQL", testSQL),
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

        if let sql = lqd.lastQuery {
            switch sql {
            case .select(let table, let filters, let joins, let groups, let orders, let limit):
                XCTAssertEqual(table, "atoms")
                XCTAssertEqual(filters.count, 0)
                XCTAssertEqual(groups.count, 0)
                XCTAssertEqual(orders.count, 0)
                XCTAssertEqual(joins.count, 1)
                if let join = joins.first {
                    XCTAssert(join.base == Atom.self)
                    XCTAssertEqual(join.joined.foreignIdKey, "compound_\(lqd.idKey)")
                    XCTAssert(join.joined == Compound.self)
                    XCTAssertEqual(join.joined.idKey, lqd.idKey)
                }
                XCTAssert(limit == nil)
            default:
                XCTFail("Invalid SQL type.")
            }
        } else {
            XCTFail("No last query.")
        }
    }

    func testCustom() throws {
        let query = try Query<Atom>(db).join(Compound.self)
        try lqd.query(query)


        if let sql = lqd.lastQuery {
            switch sql {
            case .select(let table, let filters, let joins, let groups, let orders, let limit):
                XCTAssertEqual(table, "atoms")
                XCTAssertEqual(filters.count, 0)
                XCTAssertEqual(groups.count, 0)
                XCTAssertEqual(orders.count, 0)
                XCTAssertEqual(joins.count, 1)
                if let join = joins.first {
                    XCTAssert(join.base == Atom.self)
                    XCTAssertEqual(join.joined.idKey, Compound.idKey)
                    XCTAssert(join.joined == Compound.self)
                    XCTAssertEqual(join.joined.foreignIdKey, Compound.foreignIdKey)
                }
                XCTAssert(limit == nil)
            default:
                XCTFail("Invalid SQL type.")
            }
        } else {
            XCTFail("No last query.")
        }
    }

    func testSQL() throws {
        let query = try Query<Atom>(db).join(Compound.self)
        try lqd.query(query)


        if let sql = lqd.lastQuery {
            let serializer = GeneralSQLSerializer(sql: sql)
            let (statement, values) = serializer.serialize()
            XCTAssertEqual(statement, "SELECT `atoms`.* FROM `atoms` JOIN `compounds` ON `atoms`.`#id` = `compounds`.`atom_#id`")
            XCTAssertEqual(values.count, 0)
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


        if let sql = lqd.lastQuery {
            let serializer = GeneralSQLSerializer(sql: sql)
            let (statement, values) = serializer.serialize()
            XCTAssertEqual(
                statement,
                "SELECT `atoms`.* FROM `atoms` JOIN `compounds` ON `atoms`.`#id` = `compounds`.`atom_#id` WHERE `atoms`.`protons` > ? AND `compounds`.`atoms` < ?"
            )
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
        }

        if let sql = lqd.lastQuery {
            let serializer = GeneralSQLSerializer(sql: sql)
            let (statement, values) = serializer.serialize()
            XCTAssertEqual(
                statement,
                "SELECT `compounds`.* FROM `compounds` JOIN `atom_compound` ON `compounds`.`#id` = `atom_compound`.`compound_#id` WHERE `atom_compound`.`atom_#id` = ?"
            )
            XCTAssertEqual(values.count, 1)
            XCTAssertEqual(values.first?.int, 42)
        }
    }
}
