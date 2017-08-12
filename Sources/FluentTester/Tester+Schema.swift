extension Tester {
    public func testSchema() throws {
        Student.database = database
        try Student.prepare(database)
        defer {
            try! Student.revert(database)
        }
        
        let bob = Student(
            name: "Bob",
            age: 22,
            ssn: "382482",
            donor: true,
            meta: nil // SQLite doesn't support dictionary types
        )
        try bob.save()
        
        let fetched = try Student.find(1)
        
        guard fetched?.meta == nil else {
            throw Error.failed("Student meta (nested) information failed to save or fetch.")
        }
    }
}
