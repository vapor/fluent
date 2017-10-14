import XCTest
@testable import Fluent

class OrderedPivotTests: XCTestCase {

    static let allTests = [
        ("testAttach", testAttach),
        ("testIndex", testIndex)
    ]

    var driver: SQLiteDriver!

    var database: Database!

    override func setUp() {
        super.setUp()

        do {
            self.driver = try SQLiteDriver(path: ":memory:")
            self.database = Database(self.driver)

            try Pet.prepare(self.database)
            try Toy.prepare(self.database)
            try OrderedPivot<Pet, Toy>.prepare(self.database)

        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    override func tearDown() {
        self.driver = nil
        self.database = nil
        super.tearDown()
    }

    func testAttach() throws {

        let molly = Pet(name: "Molly", age: 2)
        let rex = Pet(name: "Rex", age: 1)

        XCTAssertNoThrow(try molly.save())
        XCTAssertNoThrow(try rex.save())

        let ball = Toy(name: "ball")
        let bone = Toy(name: "bone")
        let puppet = Toy(name: "puppet")

        XCTAssertNoThrow(try ball.save())
        XCTAssertNoThrow(try bone.save())
        XCTAssertNoThrow(try puppet.save())

        XCTAssertNoThrow(try molly.toys.add(ball))
        XCTAssertNoThrow(try molly.toys.add(puppet))
        XCTAssertNoThrow(try rex.toys.add(bone))

        XCTAssertTrue(try molly.toys.isAttached(ball))
        XCTAssertTrue(try molly.toys.isAttached(puppet))
        XCTAssertTrue(try rex.toys.isAttached(bone))

        XCTAssertTrue(try ball.pets.isAttached(molly))
        XCTAssertTrue(try puppet.pets.isAttached(molly))
        XCTAssertTrue(try bone.pets.isAttached(rex))

        XCTAssertEqual(try molly.toys.all().count, 2)
        XCTAssertEqual(try Toy.makeQuery().filter("name", .hasPrefix, "b").all().count, 2)
        XCTAssertEqual(try molly.toys.makeQuery().filter("name", .hasPrefix, "b").all().count, 1)
        XCTAssertEqual(try molly.toys.makeQuery().filter("name", .hasPrefix, "b").count(), 1)
        XCTAssertEqual(try molly.toys.count(), 2)
        XCTAssertEqual(try rex.toys.all().count, 1)
        XCTAssertEqual(try rex.toys.count(), 1)

        try puppet.pets.add(rex)

        XCTAssertTrue(try rex.toys.isAttached(puppet))
        XCTAssertTrue(try puppet.pets.isAttached(rex))
        XCTAssertEqual(try rex.toys.all().count, 2)
        XCTAssertEqual(try rex.toys.count(), 2)
    }

    func testIndex() throws {

        let molly = Pet(name: "Molly", age: 2)
        let rex = Pet(name: "Rex", age: 1)

        XCTAssertNoThrow(try molly.save())
        XCTAssertNoThrow(try rex.save())

        let ball = Toy(name: "ball")
        let bone = Toy(name: "bone")
        let puppet = Toy(name: "puppet")

        XCTAssertNoThrow(try ball.save())
        XCTAssertNoThrow(try bone.save())
        XCTAssertNoThrow(try puppet.save())

        XCTAssertNoThrow(try molly.toys.add(ball))
        XCTAssertNoThrow(try molly.toys.add(puppet))
        XCTAssertNoThrow(try rex.toys.add(bone))

        XCTAssertTrue(try molly.toys.isAttached(ball))
        XCTAssertTrue(try molly.toys.isAttached(puppet))
        XCTAssertTrue(try rex.toys.isAttached(bone))

        var mollyToys = try OrderedPivot<Pet, Toy>.makeQuery().filter(Pet.foreignIdKey, molly.id).sort("index", .ascending).all()
        let rexToys = try OrderedPivot<Pet, Toy>.makeQuery().filter(Pet.foreignIdKey, rex.id).sort("index", .ascending).all()

        XCTAssertEqual(mollyToys[0].rightId, ball.id)
        XCTAssertEqual(mollyToys[1].rightId, puppet.id)
        XCTAssertEqual(rexToys[0].rightId, bone.id)
        XCTAssertEqual(mollyToys[0].index, 1)
        XCTAssertEqual(mollyToys[1].index, 2)
        XCTAssertEqual(rexToys[0].index, 1)

        let invertedMollyToys = try OrderedPivot<Pet, Toy>.makeQuery().filter(Pet.foreignIdKey, molly.id).sort("index", .descending).all()
        let invertedRexToys = try OrderedPivot<Pet, Toy>.makeQuery().filter(Pet.foreignIdKey, rex.id).sort("index", .descending).all()

        XCTAssertEqual(invertedMollyToys[0].rightId, puppet.id)
        XCTAssertEqual(invertedMollyToys[1].rightId, ball.id)
        XCTAssertEqual(invertedRexToys[0].rightId, bone.id)
        XCTAssertEqual(invertedMollyToys[0].index, 2)
        XCTAssertEqual(invertedMollyToys[1].index, 1)
        XCTAssertEqual(invertedRexToys[0].index, 1)

        XCTAssertNoThrow(try molly.toys.remove(ball))
        XCTAssertNoThrow(try molly.toys.add(ball))

        mollyToys = try OrderedPivot<Pet, Toy>.makeQuery().filter(Pet.foreignIdKey, molly.id).sort("index", .ascending).all()

        XCTAssertEqual(mollyToys[0].rightId, puppet.id)
        XCTAssertEqual(mollyToys[1].rightId, ball.id)
        XCTAssertEqual(mollyToys[0].index, 2)
        XCTAssertEqual(mollyToys[1].index, 3)
    }
}
