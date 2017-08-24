extension Tester {
    public func test(_ f: () throws -> (), _ name: String) throws {
        do {
            try f()
        } catch {
            throw Error.failed("\(name) failed: \(error)")
        }
    }
    
    public func testEquals<E: Entity>(_ a1: [E], _ a2: [E]) throws {
        guard a1.count == a2.count else {
            throw Error.failed("\(E.self) array count does not match")
        }

        let a1_ids = a1.flatMap({ $0.id })

        for a2 in a2 {
            if !a1_ids.contains(a2.id ?? -1) {
                throw Error.failed("\(E.self) array does not contain entity with id: \(a2.id ?? "nil")")
            }
        }
    }
    
    
}
