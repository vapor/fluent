extension Tester {
    public func testIndex() throws {
        Atom.database = database
        
        try Atom.prepare(database)
        defer {
            try! Atom.revert(database)
        }
        
        try database.index("name", for: Atom.self)
        do {
            try database.index("name", for: Atom.self)
        } catch {
            // pass
        }
        try database.index("protons", for: Atom.self)
        try database.index("weight", for: Atom.self)
        
        try database.deleteIndex("name", for: Atom.self)
        try database.deleteIndex("protons", for: Atom.self)
        try database.deleteIndex("weight", for: Atom.self)
        do {
            try database.deleteIndex("weight", for: Atom.self)
        } catch {
            // pass
        }
        try database.index("name", for: Atom.self)
    }
}
