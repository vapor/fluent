import XCTest
@testable import Fluent

class SchemaCreateTests: XCTestCase {
    static let allTests = [
        ("testCreate", testCreate),
        ("testStringDefault", testStringDefault),
        ("testForeignKey", testForeignKey),
        ("testModify", testModify),
        ("testDelete", testDelete),
    ]

    var db: Database!

    override func setUp() {
        let lqd = LastQueryDriver()
        db = Database(lqd)
    }

    func testCreate() throws {
        let builder = Creator(Atom.self)

        builder.int("id")
        builder.string("name")
        builder.string("email", length: 256)
        builder.custom("profile", type: "JSON")

        let query = Query<Atom>(db)
        query.action = .schema(.create(
            fields: builder.fields,
            foreignKeys: []
        ))

        let serializer = GeneralSQLSerializer(query)
        let (statement, values) = serializer.serialize()

        XCTAssertEqual(statement, "CREATE TABLE `atoms` (`id` INTEGER NOT NULL, `name` STRING NOT NULL, `email` STRING NOT NULL, `profile` JSON NOT NULL)")
        XCTAssertEqual(values.count, 0)
    }

    func testForeignKey() throws {
        let builder = Creator(Atom.self)

        builder.int("id")
        builder.string("name")
        builder.foreignId(for: Group.self, optional: true, onUpdate: .noAction, onDelete: .setNull)

        let query = Query<Atom>(db)
        query.action = .schema(.create(
            fields: builder.fields,
            foreignKeys: builder.foreignKeys
        ))

        let serializer = GeneralSQLSerializer(query)
        let (statement, values) = serializer.serialize()

        XCTAssertEqual(statement, "CREATE TABLE `atoms` (`id` INTEGER NOT NULL, `name` STRING NOT NULL, `group_id` INTEGER, CONSTRAINT `_fluent_fk_atoms.group_id-groups.id` FOREIGN KEY (`group_id`) REFERENCES `groups` (`id`) ON UPDATE NO ACTION ON DELETE SET NULL)")
        XCTAssertEqual(values.count, 0)
    }
    
    func testStringIdentifiedEntity() throws {
        let builder = Creator(StringIdentifiedThing.self)
        
        builder.id()

        let query = Query<StringIdentifiedThing>(db)
        query.action = .schema(.create(
            fields: builder.fields,
            foreignKeys: []
        ))
        let serializer = GeneralSQLSerializer(query)
        
        let (statement, values) = serializer.serialize()
        
        XCTAssertEqual(statement, "CREATE TABLE `string_identified_things` (`#id` STRING(10) PRIMARY KEY NOT NULL)")
        XCTAssertEqual(values.count, 0)
    }
 
    
    func testCustomIdentifiedEntity() throws {
        let builder = Creator(CustomIdentifiedThing.self)
        
        builder.id()
        
        let query = Query<CustomIdentifiedThing>(db)
        query.action = .schema(.create(
            fields: builder.fields,
            foreignKeys: []
        ))
        let serializer = GeneralSQLSerializer(query)
        
        let (statement, values) = serializer.serialize()
        
        XCTAssertEqual(statement, "CREATE TABLE `custom_identified_things` (`#id` INTEGER PRIMARY KEY NOT NULL)")
        XCTAssertEqual(values.count, 0)
    }
    
    func testStringDefault() throws {
        let builder = Creator(Atom.self)
        
        builder.string("string", default: "default")
        
        let query = Query<Atom>(db)
        query.action = .schema(.create(
            fields: builder.fields,
            foreignKeys: []
        ))
        let serializer = GeneralSQLSerializer(query)
        
        let (statement, values) = serializer.serialize()
        
        XCTAssertEqual(statement, "CREATE TABLE `atoms` (`string` STRING NOT NULL DEFAULT 'default')")
        XCTAssertEqual(values.count, 0)
    }

    func testModify() throws {
        let builder = Modifier(Atom.self)

        builder.int("id")
        builder.string("name")
        builder.string("email", length: 256)
        builder.delete("age")

        let query = Query<Atom>(db)
        query.action = .schema(.modify(
            fields: builder.fields,
            foreignKeys: [],
            deleteFields: builder.deleteFields,
            deleteForeignKeys: []
        ))
        let serializer = GeneralSQLSerializer(query)

        let (statement, values) = serializer.serialize()

        XCTAssertEqual(statement, "ALTER TABLE `atoms` ADD `id` INTEGER NOT NULL, ADD `name` STRING NOT NULL, ADD `email` STRING NOT NULL, DROP `age`")
        XCTAssertEqual(values.count, 0)
    }

    func testDelete() throws {
        let query = Query<Atom>(db)
        query.action = .schema(.delete)
        let serializer = GeneralSQLSerializer(query)

        let (statement, values) = serializer.serialize()

        XCTAssertEqual(statement, "DROP TABLE IF EXISTS `atoms`")
        XCTAssertEqual(values.count, 0)
    }
}
