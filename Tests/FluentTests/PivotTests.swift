import XCTest
@testable import Fluent

class PivotTests: XCTestCase {
    var lqd: LastQueryDriver!
    var db: Database!

    override func setUp() {
        lqd = LastQueryDriver()
        db = Database(lqd)
        db.usesTimestamps = false
    }

    func testEntityAttach() throws {
        Pivot<Atom, Compound>.database = db
        let atom = Atom(name: "Hydrogen")
        atom.id = 42
        atom.exists = true

        let compound = Compound(name: "Water")
        compound.id = 1337
        compound.exists = true

        try atom.compounds.add(compound)

        guard let (sql, _) = lqd.lastQuery else {
            XCTFail("No query recorded")
            return
        }

        XCTAssertEqual(
            sql,
            "INSERT INTO `atom_compound` (`\(Atom.foreignIdKey)`, `\(Compound.foreignIdKey)`) VALUES (?, ?)"
        )
    }

    static let allTests = [
        ("testEntityAttach", testEntityAttach),
    ]
}
