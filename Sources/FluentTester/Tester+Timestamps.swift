import libc

extension Tester {
    public func testTimestamps() throws {
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

        let compounds = try Compound.all()

        let now = Date()
        for compound in compounds {
            guard let createdAt = compound.createdAt else {
                throw Error.failed("Compound \(compound.name) did not have a created at")
            }

            guard createdAt.isWithin(seconds: 1, of: now) else {
                throw Error.failed("Created at wasn't right")
            }
        }

        sleep(2)

        water.name = "water 2.0"
        try water.save()

        guard water.updatedAt?.isWithin(seconds: 1, of: Date()) == true else {
            throw Error.failed("Updated at didn't change")
        }

        guard let fetched = try Compound.find(water.id) else {
            throw Error.failed("Could not find water")
        }

        guard water.updatedAt?.unix == fetched.updatedAt?.unix else {
            throw Error.failed("Fetched does not equal saved for updated at")
        }

        guard water.createdAt?.unix == fetched.createdAt?.unix else {
            throw Error.failed("Fetched does not equal saved for created at")
        }
    }
}

extension Date {
    public func isWithin(seconds: Double, of other: Date) -> Bool {
        var diff = other.timeIntervalSince1970 - self.timeIntervalSince1970
        if diff < 0 {
            diff = diff * -1.0
        }
        return diff <= seconds
    }

    public var unix: Int {
        return Int(timeIntervalSince1970)
    }
}
