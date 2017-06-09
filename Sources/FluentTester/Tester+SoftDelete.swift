import libc

extension Tester {
    public func testSoftDelete() throws {
        Compound.database = database
        try Compound.prepare(database)
        defer {
            try? Compound.revert(database)
        }

        let ethanol = Compound(name: "Ethanol")
        let hcl = Compound(name: "Hydrochloric Acid")
        let methanol = Compound(name: "Methanol")
        let water = Compound(name: "Water")

        try ethanol.save()
        try hcl.save()
        try methanol.save()
        try water.save()

        guard try Compound.count() == 4 else {
            throw Error.failed("Compound count did not equal 4")
        }

        try water.delete()

        guard try Compound.count() == 3 else {
            throw Error.failed("Compound count did not go down to 3")
        }

        guard try Compound.all().count == 3 else {
            throw Error.failed("Compound all did not go down to 3")
        }

        guard let fetched = try Compound.withSoftDeleted().find(water.id) else {
            throw Error.failed("Soft deleted should be fetchable by id")
        }

        guard try Compound.makeQuery().filter("name", "Water").all().count == 0 else {
            throw Error.failed("Soft deleted should not be fetchable by query")
        }

        try fetched.restore()

        guard try Compound.count() == 4 else {
            throw Error.failed("Compound count did not equal 4 after restore.")
        }

        try fetched.forceDelete()

        guard try Compound.count() == 3 else {
            throw Error.failed("Compound count did not equal 3 after force delete.")
        }

        guard try Compound.withSoftDeleted().find(water.id) == nil else {
            throw Error.failed("Water was not forced deleted")
        }

        try Compound.makeQuery().delete()

        guard try Compound.count() == 0 else {
            throw Error.failed("Compound count did not equal 0 after delete.")
        }

        guard try Compound.withSoftDeleted().count() == 3 else {
            throw Error.failed("Water was not soft deleted")
        }

        try Compound.makeQuery().forceDelete()

        guard try Compound.withSoftDeleted().count() == 0 else {
            throw Error.failed("Water was not force deleted")
        }
    }
}

extension Compound: SoftDeletable { }
