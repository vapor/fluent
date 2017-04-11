private enum _Error: Error { case test }

extension Tester {
    public func testTransaction() throws {
        guard let driver = database.driver as? Transactable else {
            print("Skipping testTransaction because driver is not Transactable")
            return
        }
        
        Compound.database = database
        try Compound.prepare(database)
        defer {
            try! Compound.revert(database)
        }
        
        
        let compound = Compound(name: "Test 0")
        try compound.save()
        
        do {
            try driver.transaction { conn in
                for i in 1...128 {
                    let compound = Compound(name: "Test \(i)")
                    try compound.makeQuery(conn).save()
                }
                let count = try Compound.makeQuery(conn).count()
                guard count == 129 else {
                    throw Error.failed("Count \(count) did not equal 129")
                }
                throw _Error.test
            }
            throw Error.failed("No error thrown")
        } catch _Error.test {}

        
        let count = try Compound.count()
        guard count == 1 else {
            throw Error.failed("Count \(count) did not equal 1")
        }
    }
}
