import Fluent

extension Tester {
    public func testPivotsAndRelations() throws {
        try Atom.prepare(database)
        try Compound.prepare(database)
        try BasicPivot<Atom, Compound>.prepare(database)
        
        defer {
            try? Atom.revert(database)
            try? Compound.revert(database)
            try? BasicPivot<Atom, Compound>.revert(database)
        }

        Atom.database = database
        Compound.database = database
        BasicPivot<Atom, Compound>.database = database

        var hydrogen = Atom(id: nil, name: "Hydrogen", protons: 1, weight: 1.007)
        try hydrogen.save()

        var carbon = Atom(id: nil, name: "Carbon", protons: 6, weight: 12.011)
        try carbon.save()

        var oxygen = Atom(id: nil, name: "Oxygen", protons: 8, weight: 15.999)
        try oxygen.save()

        var water = Compound(id: nil, name: "Water")
        try water.save()
        try BasicPivot<Atom, Compound>.attach(hydrogen, water)
        try BasicPivot<Atom, Compound>.attach(oxygen, water)

        var sugar = Compound(id: nil, name: "Sugar")
        try sugar.save()
        try BasicPivot<Atom, Compound>.attach(hydrogen, sugar)
        try BasicPivot<Atom, Compound>.attach(oxygen, sugar)
        try BasicPivot<Atom, Compound>.attach(carbon, sugar)

        let hydrogenCompounds = try hydrogen.compounds().all()
        try testEquals(hydrogenCompounds, [water, sugar])
        let carbonCompounds = try carbon.compounds().all()
        try testEquals(carbonCompounds, [sugar])
        let oxygenCompounds = try oxygen.compounds().all()
        try testEquals(oxygenCompounds, [water, sugar])

        let sugarAtoms = try sugar.atoms().all()
        try testEquals(sugarAtoms, [carbon, oxygen, hydrogen])
        let waterAtoms = try water.atoms().all()
        try testEquals(waterAtoms, [oxygen, hydrogen])
    }
}
