extension Tester {
    public func testPaginate() throws {
        Compound.database = database
        try Compound.prepare(database)
        defer {
            try! Compound.revert(database)
        }

        let ethanol = Compound(name: "Ethanol")
        let hcl = Compound(name: "Hydrochloric Acid")
        let methanol = Compound(name: "Methanol")
        let water = Compound(name: "Water")

        try ethanol.save()
        try hcl.save()
        try methanol.save()
        try water.save()

        let page = try Compound
            .query()
            .paginate(page: 2)

        guard page.data.count == 2 else {
            throw Error.failed("Page data count did not equal 2.")
        }

        guard page.data.first?.name == "Methanol" else {
            throw Error.failed("Page data failed. Expected methanol got \(page.data.first?.name ?? "nil")")
        }

        guard page.data.last?.name == "Water" else {
            throw Error.failed("Page data failed. Expected water got \(page.data.last?.name ?? "nil")")
        }

        guard page.total == 4 else {
            throw Error.failed("Expected 4 in total.")
        }

        guard page.number == 2 else {
            throw Error.failed("Expected page 2.")
        }

        guard page.size == 2 else {
            throw Error.failed("Expected page size to be 2.")
        }
    }
}
