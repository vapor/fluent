import XCTest
@testable import Fluent

class ModelTests: XCTestCase {
    static let allTests = [
        ("testExamples", testExamples),
    ]

    var lqd: LastQueryDriver!
    var db: Database!

    override func setUp() {
        lqd = LastQueryDriver()
        db = Database(lqd)
    }

    func testExamples() throws {
        Atom.database = db
        var atom = Atom(name: "test")

        atom.id = 5
        print(atom.exists)
        try! atom.save()

        let (sql, _) = GeneralSQLSerializer(sql: lqd.lastQuery!).serialize()
        print(sql)

        atom.name = "bob"
        try atom.save()

        print(atom.exists)

        let (sql2, _) = GeneralSQLSerializer(sql: lqd.lastQuery!).serialize()
        print(sql2)

        print(atom.id)

        try atom.delete()
    }
}
