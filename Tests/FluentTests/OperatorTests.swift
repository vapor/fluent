import Fluent
import Testing
import Vapor
import VaporTesting
import XCTFluent

@Suite
struct OperatorTests {
    @Test
    func customOperators() throws {
        // TODO: What does this test...?
        let db = DummyDatabase()

        // name contains string anywhere, prefix, suffix
        _ = Planet.query(on: db)
            .filter(\.$name ~~ "art")
        _ = Planet.query(on: db)
            .filter(\.$name =~ "art")
        _ = Planet.query(on: db)
            .filter(\.$name ~= "art")
        // name doesn't contain string anywhere, prefix, suffix
        _ = Planet.query(on: db)
            .filter(\.$name !~ "art")
        _ = Planet.query(on: db)
            .filter(\.$name !=~ "art")
        _ = Planet.query(on: db)
            .filter(\.$name !~= "art")

        // name in array
        _ = Planet.query(on: db)
            .filter(\.$name ~~ ["Earth", "Mars"])
        // name not in array
        _ = Planet.query(on: db)
            .filter(\.$name !~ ["Earth", "Mars"])
    }
}

private final class Planet: Model, @unchecked Sendable {
    static let schema = "planets"

    @ID(custom: .id)
    var id: Int?

    @Field(key: "name")
    var name: String
}
