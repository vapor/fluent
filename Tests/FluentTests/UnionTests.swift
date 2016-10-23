import XCTest
@testable import Fluent

class UnionTests: XCTestCase {
    static let allTests = [
        ("testBasic", testBasic),
        ("testCustom", testCustom),
        ("testSQL", testSQL),
        ("testSQLFilters", testSQLFilters),
        ("testBelongsToMany", testBelongsToMany),
        ("testRelationFields", testRelationFields),
        ("testRelationFields", testRetrieveRelation),
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
            case .select(let table, let fields, let relations, let filters, let joins, let orders, let limit):
                XCTAssertEqual(table, "atoms")
                XCTAssertEqual(fields.count, 0)
                XCTAssertEqual(relations.count, 0)
                XCTAssertEqual(filters.count, 0)
                XCTAssertEqual(orders.count, 0)
                XCTAssertEqual(joins.count, 1)
                if let join = joins.first {
                    XCTAssert(join.local == Atom.self)
                    XCTAssertEqual(join.localKey, "compound_\(lqd.idKey)")
                    XCTAssert(join.foreign == Compound.self)
                    XCTAssertEqual(join.foreignKey, lqd.idKey)
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
        let localKey = "#local_key"
        let foreignKey = "#foreign_key"

        let query = try Query<Atom>(db).union(Compound.self, localKey: localKey, foreignKey: foreignKey)
        try lqd.query(query)


        if let sql = lqd.lastQuery {
            switch sql {
            case .select(let table, let fields, let relations, let filters, let joins, let orders, let limit):
                XCTAssertEqual(table, "atoms")
                XCTAssertEqual(fields.count, 0)
                XCTAssertEqual(relations.count, 0)
                XCTAssertEqual(filters.count, 0)
                XCTAssertEqual(orders.count, 0)
                XCTAssertEqual(joins.count, 1)
                if let join = joins.first {
                    XCTAssert(join.local == Atom.self)
                    XCTAssertEqual(join.localKey, localKey)
                    XCTAssert(join.foreign == Compound.self)
                    XCTAssertEqual(join.foreignKey, foreignKey)
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
        let localKey = "#local_key"
        let foreignKey = "#foreign_key"

        let query = try Query<Atom>(db).union(Compound.self, localKey: localKey, foreignKey: foreignKey)
        try lqd.query(query)


        if let sql = lqd.lastQuery {
            let serializer = GeneralSQLSerializer(sql: sql)
            let (statement, values) = serializer.serialize()
            XCTAssertEqual(statement, "SELECT `atoms`.* FROM `atoms` JOIN `compounds` ON `atoms`.`#local_key` = `compounds`.`#foreign_key`")
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
            XCTAssertEqual(statement, "SELECT `atoms`.* FROM `atoms` JOIN `compounds` ON `atoms`.`#local_key` = `compounds`.`#foreign_key` WHERE `atoms`.`protons` > ? AND `compounds`.`atoms` < ?")

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

        var atom = Atom(name: "Hydrogen")
        atom.id = Node(42)

        do {
            _ = try atom.compounds().all()
        }

        if let sql = lqd.lastQuery {
            let serializer = GeneralSQLSerializer(sql: sql)
            let (statement, values) = serializer.serialize()
            XCTAssertEqual(
                statement,
                "SELECT `compounds`.`id`, `compounds`.`name` FROM `compounds` JOIN `atom_compound` ON `compounds`.`\(lqd.idKey)` = `atom_compound`.`compound_\(lqd.idKey)` WHERE `atom_compound`.`atom_\(lqd.idKey)` = ?"
            )
            XCTAssertEqual(values.count, 1)
            XCTAssertEqual(values.first?.int, 42)
        }
    }
    
    func testRelationFields() throws {
        let localKey = "#local_key"
        let foreignKey = "#foreign_key"

        let query = try Query<Atom>(db).union(Compound.self, localKey: localKey, foreignKey: foreignKey)
        query.fields = Atom.fields(for: db)
        query.relationFields = [(Compound.entity, Compound.fields(for: db))]
        try lqd.query(query)

        if let sql = lqd.lastQuery {
            let serializer = GeneralSQLSerializer(sql: sql)
            let (statement, values) = serializer.serialize()
            XCTAssertEqual(statement, "SELECT `atoms`.`id`, `atoms`.`name`, `atoms`.`group_id`, `compounds`.`id` AS `compounds_id`, `compounds`.`name` AS `compounds_name` FROM `atoms` JOIN `compounds` ON `atoms`.`#local_key` = `compounds`.`#foreign_key`")
            XCTAssertEqual(values.count, 0)
        } else {
            XCTFail("No last query.")
        }
    }
    
    func testRetrieveRelation() throws {
        Atom.database = db
        Compound.database = db
        
        let localKey = "#local_key"
        let foreignKey = "#foreign_key"

        do {
            _ = try Atom.query()
                .union(Compound.self, localKey: localKey, foreignKey: foreignKey)
                .all(including: Compound.self)
        }

        if let sql = lqd.lastQuery {
            let serializer = GeneralSQLSerializer(sql: sql)
            let (statement, values) = serializer.serialize()
            XCTAssertEqual(
                statement,
                "SELECT `atoms`.`id`, `atoms`.`name`, `atoms`.`group_id`, `compounds`.`id` AS `compounds_id`, `compounds`.`name` AS `compounds_name` FROM `atoms` JOIN `compounds` ON `atoms`.`#local_key` = `compounds`.`#foreign_key`"
            )
            XCTAssertEqual(values.count, 0)
        }
    }
}
