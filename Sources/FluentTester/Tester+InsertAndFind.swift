import Fluent
import XCTest

extension Tester {
    public func testInsertAndFind() throws {
        try Atom.prepare(database)
        Atom.database = database

        var hydrogen = Atom(id: nil, name: "Hydrogen", protons: 1, weight: 1.007)

        XCTAssertEqual(hydrogen.exists, false)
        try hydrogen.save()
        XCTAssertEqual(hydrogen.exists, true)

        guard let id = hydrogen.id else {
            XCTFail("ID not set on Atom after save.")
            return
        }

        guard let found = try Atom.find(id) else {
            throw Error.failed("Could not find Atom by id.")
        }

        XCTAssertEqual(hydrogen.id, found.id)
        XCTAssertEqual(hydrogen.name, found.name)
        XCTAssertEqual(hydrogen.protons, found.protons)
        XCTAssertEqual(hydrogen.weight, found.weight)
        
        try Atom.revert(database)
    }
}
