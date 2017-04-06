extension Tester {
    public func testChunk() throws {
        Compound.database = database
        try Compound.prepare(database)
        defer {
            try! Compound.revert(database)
        }
        
        for i in 0..<2048 {
            let compound = Compound(name: "Test \(i)")
            try compound.save()
        }
        
        var fetched: [Compound] = []
        try Compound.chunk(33) { chunk in
            fetched += chunk
        }
        
        guard fetched.count == 2048 else {
            throw Error.failed("Chunked fetched count was not correct")
        }
        
        for i in 0..<2048 {
            guard fetched[i].name == "Test \(i)" else {
                throw Error.failed("Wrong name")
            }
        }
    }
}
