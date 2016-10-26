import Fluent
import XCTest

extension Tester {
    public func testPivotsAndRelations() throws {
        try Atom.prepare(database)
        try Compound.prepare(database)
        try Pivot<Atom, Compound>.prepare(database)

        Atom.database = database
        Compound.database = database
        Pivot<Atom, Compound>.database = database

        var hydrogen = Atom(id: nil, name: "Hydrogen", protons: 1, weight: 1.007)
        try hydrogen.save()

        var carbon = Atom(id: nil, name: "Carbon", protons: 6, weight: 12.011)
        try carbon.save()

        var oxygen = Atom(id: nil, name: "Oxygen", protons: 8, weight: 15.999)
        try oxygen.save()

        var water = Compound(id: nil, name: "Water")
        try water.save()
        var hydrogenWater = Pivot<Atom, Compound>(hydrogen, water)
        try hydrogenWater.save()
        var oxygenWater = Pivot<Atom, Compound>(oxygen, water)
        try oxygenWater.save()

        var sugar = Compound(id: nil, name: "Sugar")
        try sugar.save()
        var hydrogenSugar = Pivot<Atom, Compound>(hydrogen, sugar)
        try hydrogenSugar.save()
        var oxygenSugar = Pivot<Atom, Compound>(oxygen, sugar)
        try oxygenSugar.save()
        var carbonSugar = Pivot<Atom, Compound>(carbon, sugar)
        try carbonSugar.save()

        let hydrogenCompounds = try hydrogen.compounds().all()
        testEquals(hydrogenCompounds, [water, sugar])
        let carbonCompounds = try carbon.compounds().all()
        testEquals(carbonCompounds, [sugar])
        let oxygenCompounds = try oxygen.compounds().all()
        testEquals(oxygenCompounds, [water, sugar])

        let sugarAtoms = try sugar.atoms().all()
        testEquals(sugarAtoms, [carbon, oxygen, hydrogen])
        let waterAtoms = try water.atoms().all()
        testEquals(waterAtoms, [oxygen, hydrogen])

        try Atom.revert(database)
        try Compound.revert(database)
        try Pivot<Atom, Compound>.revert(database)
    }
}
