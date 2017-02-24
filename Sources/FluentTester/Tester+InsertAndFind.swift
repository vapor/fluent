extension Tester {
    public func testInsertAndFind() throws {
        Atom.database = database
        try Atom.prepare(database)
        defer {
            try? Atom.revert(database)
        }

        let hydrogen = Atom(id: nil, name: "Hydrogen", protons: 1, weight: 1.007)

        guard hydrogen.exists == false else {
            throw Error.failed("Exists should be false since not yet saved.")
        }
        try hydrogen.save()
        
        guard hydrogen.exists == true else {
            throw Error.failed("Exists should be true since just saved.")
        }

        guard let id = hydrogen.id else {
            throw Error.failed("ID not set on Atom after save.")
        }

        guard let found = try Atom.find(id) else {
            throw Error.failed("Could not find Atom by id.")
        }

        guard hydrogen.id == found.id else {
            throw Error.failed("ID retrieved different than what was saved.")
        }
        
        guard hydrogen.name == found.name else {
            throw Error.failed("Name retrieved different than what was saved.")
        }
        
        guard hydrogen.protons == found.protons else {
            throw Error.failed("Protons retrieved different than what was saved.")
        }
        
        guard hydrogen.weight == found.weight else {
            throw Error.failed("Weight retrieved different than what was saved.")
        }
        
    }
}
