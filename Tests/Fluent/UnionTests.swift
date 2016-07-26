import XCTest
@testable import Fluent

class UnionTests: XCTestCase {
    static let allTests = [
        ("testBasic", testBasic),
        ("testCustom", testCustom),
        ("testSQL", testSQL),
        ("testSQLFilters", testSQLFilters),
    ]

    var lqd: LastQueryDriver!
    var db: Database!

    override func setUp() {
        lqd = LastQueryDriver()
        db = Database(lqd)
    }

    func testBasic() throws {
        let query = try Query<Atom>(db).union(Compound.self)
        try lqd.query(query)

        if let sql = lqd.lastQuery {
            switch sql {
            case .select(let table, let filters, let joins, let limit):
                XCTAssertEqual(table, "atoms")
                XCTAssertEqual(filters.count, 0)
                XCTAssertEqual(joins.count, 1)
                if let join = joins.first {
                    XCTAssert(join.local == Atom.self)
                    XCTAssertEqual(join.localKey, "compound_\(lqd.idKey)")
                    XCTAssert(join.foreign == Compound.self)
                    XCTAssertEqual(join.foreignKey, lqd.idKey)
                }
                XCTAssertEqual(limit, nil)
            default:
                XCTFail("Invalid SQL type.")
            }
        } else {
            XCTFail("No last query.")
        }
    }

    func testCustom() throws {
        let localKey = "#local_key"
        let foreignKey = "#foreign_key"

        let query = try Query<Atom>(db).union(Compound.self, localKey: localKey, foreignKey: foreignKey)
        try lqd.query(query)


        if let sql = lqd.lastQuery {
            switch sql {
            case .select(let table, let filters, let joins, let limit):
                XCTAssertEqual(table, "atoms")
                XCTAssertEqual(filters.count, 0)
                XCTAssertEqual(joins.count, 1)
                if let join = joins.first {
                    XCTAssert(join.local == Atom.self)
                    XCTAssertEqual(join.localKey, localKey)
                    XCTAssert(join.foreign == Compound.self)
                    XCTAssertEqual(join.foreignKey, foreignKey)
                }
                XCTAssertEqual(limit, nil)
            default:
                XCTFail("Invalid SQL type.")
            }
        } else {
            XCTFail("No last query.")
        }
    }

    func testSQL() throws {
        let localKey = "#local_key"
        let foreignKey = "#foreign_key"

        let query = try Query<Atom>(db).union(Compound.self, localKey: localKey, foreignKey: foreignKey)
        try lqd.query(query)


        if let sql = lqd.lastQuery {
            let serializer = GeneralSQLSerializer(sql: sql)
            let (statement, values) = serializer.serialize()
            XCTAssertEqual(statement, "SELECT * FROM `atoms` JOIN `compounds` ON `atoms`.`#local_key` = `compounds`.`#foreign_key`")
            XCTAssertEqual(values.count, 0)
        } else {
            XCTFail("No last query.")
        }
    }

    func testSQLFilters() throws {
        let localKey = "#local_key"
        let foreignKey = "#foreign_key"

        let query = try Query<Atom>(db)
            .union(Compound.self, localKey: localKey, foreignKey: foreignKey)
            .filter("protons", .greaterThan, 5)
            .filter(Compound.self, "atoms", .lessThan, 128)

        try lqd.query(query)


        if let sql = lqd.lastQuery {
            let serializer = GeneralSQLSerializer(sql: sql)
            let (statement, values) = serializer.serialize()
            XCTAssertEqual(statement, "SELECT * FROM `atoms` JOIN `compounds` ON `atoms`.`#local_key` = `compounds`.`#foreign_key` WHERE `atoms`.`protons` > ? AND `compounds`.`atoms` < ?")

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

    func testBelongsToMany() throws {
        Atom.database = db
        Compound.database = db

        let atom = Atom(name: "Hydrogen", protons: 1)
        atom.id = Node(42)

        do {
            _ = try atom.compounds().all()
        }

        if let sql = lqd.lastQuery {
            let serializer = GeneralSQLSerializer(sql: sql)
            let (statement, values) = serializer.serialize()
            XCTAssertEqual(
                statement,
                "SELECT * FROM `compounds` JOIN `atom_compound` ON `compounds`.`\(lqd.idKey)` = `atom_compound`.`compound_\(lqd.idKey)` WHERE `atom_compound`.`atom_\(lqd.idKey)` = ?"
            )
            XCTAssertEqual(values.count, 1)
            XCTAssertEqual(values.first?.int, 42)
        }
    }
}
