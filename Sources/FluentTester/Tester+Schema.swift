import Fluent

extension Tester {
    public func testSchema() throws {
        Student.database = database
        
        try Student.prepare(database)
        defer {
            try? Student.revert(database)
        }
        
        var bob = Student(
            name: "Bob",
            age: 22,
            ssn: "382482",
            donor: true,
            meta: Node.object([
                "hello": Node.string("world")
            ])
        )
        try bob.save()
        
        let fetched = try Student.find(1)
        
        guard fetched?.meta["hello"]?.string == "world" else {
            throw Error.failed("Student meta (nested) information failed to save or fetch.")
        }
    }
}
