import Fluent

extension Tester {
    public func testPivotsAndRelations() throws {
        try Atom.prepare(database)
        try Compound.prepare(database)
        try Pivot<Atom, Compound>.prepare(database)
        
        defer {
            try? Atom.revert(database)
            try? Compound.revert(database)
            try? Pivot<Atom, Compound>.revert(database)
        }

        Atom.database = database
        Compound.database = database
        Pivot<Atom, Compound>.database = database

        let hydrogen = Atom(id: nil, name: "Hydrogen", protons: 1, weight: 1.007)
        try hydrogen.save()

        let carbon = Atom(id: nil, name: "Carbon", protons: 6, weight: 12.011)
        try carbon.save()

        let oxygen = Atom(id: nil, name: "Oxygen", protons: 8, weight: 15.999)
        try oxygen.save()

        let water = Compound(id: nil, name: "Water")
        try water.save()
        try Pivot<Atom, Compound>.attach(hydrogen, water)
        try Pivot<Atom, Compound>.attach(oxygen, water)

        let sugar = Compound(id: nil, name: "Sugar")
        try sugar.save()
        try Pivot<Atom, Compound>.attach(hydrogen, sugar)
        try Pivot<Atom, Compound>.attach(oxygen, sugar)
        try Pivot<Atom, Compound>.attach(carbon, sugar)

        let hydrogenCompounds = try hydrogen.compounds.all()
        try testEquals(hydrogenCompounds, [water, sugar])
        let carbonCompounds = try carbon.compounds.all()
        try testEquals(carbonCompounds, [sugar])
        let oxygenCompounds = try oxygen.compounds.all()
        try testEquals(oxygenCompounds, [water, sugar])

        let sugarAtoms = try sugar.atoms.all()
        try testEquals(sugarAtoms, [carbon, oxygen, hydrogen])
        let waterAtoms = try water.atoms.all()
        try testEquals(waterAtoms, [oxygen, hydrogen])
    }

    public func testDoublePivot() throws {
        let driver = MemoryDriver()
        let database = Database(driver)

        try Atom.prepare(database)
        try Compound.prepare(database)
        try Student.prepare(database)
        try Pivot<Atom, Compound>.prepare(database)
        try Pivot<Pivot<Atom, Compound>, Student>.prepare(database)

        defer {
            try? Atom.revert(database)
            try? Compound.revert(database)
            try? Pivot<Atom, Compound>.revert(database)
            try? Pivot<Pivot<Atom, Compound>, Student>.revert(database)
        }

        Atom.database = database
        Compound.database = database
        Student.database = database
        Pivot<Atom, Compound>.database = database
        Pivot<Pivot<Atom, Compound>, Student>.database = database

        let hydrogen = Atom(id: nil, name: "Hydrogen", protons: 1, weight: 1.007)
        try hydrogen.save()

        let water = Compound(id: nil, name: "Water")
        try water.save()

        let vapor = Student(
            name: "Vapor",
            age: 2,
            ssn: "123",
            donor: false,
            meta: nil
        )
        try vapor.save()

        let hydrogenWater = try Pivot<Atom, Compound>(hydrogen, water)
        try hydrogenWater.save()

        let hwVapor = try Pivot<Pivot<Atom, Compound>, Student>(hydrogenWater, vapor)
        try hwVapor.save()

        let pivot1 = Pivot<Student, Pivot<Atom, Compound>>.self
        let result1 = try pivot1.related(
            left: vapor,
            middle: hydrogen,
            right: water
        )
        guard result1 else {
            throw Error.failed("Pivot relation failed.")
        }

        let pivot2 = Pivot<Pivot<Atom, Compound>, Student>.self
        let result2 = try pivot2.related(
            left: hydrogen,
            middle: water,
            right: vapor
        )
        guard result2 else {
            throw Error.failed("Pivot relation failed.")
        }

        let helium = Atom(id: nil, name: "Helium", protons: 2, weight: 2.007)
        try helium.save()

        let result3 = try pivot1.related(
            left: vapor,
            middle: helium,
            right: water
        )
        guard !result3 else {
            throw Error.failed("Pivot relation failed.")
        }

        let result4 = try pivot2.related(
            left: helium,
            middle: water,
            right: vapor
        )
        guard !result4 else {
            throw Error.failed("Pivot relation failed.")
        }
    }
}
