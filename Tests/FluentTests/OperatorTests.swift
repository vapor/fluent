import Fluent
import Testing
import Vapor
import VaporTesting
import XCTFluent

@Suite
struct OperatorTests {
    @Test
    func customOperators() throws {
        let db = DummyDatabase()

        // name contains string anywhere, prefix, suffix
        #expect(
            Planet.query(on: db)
                .filter(\.$name ~~ "art").query.description
                == #"query read planets filters=[planets[name] contains "art"]"#
        )
        #expect(
            Planet.query(on: db)
                .filter(\.$name =~ "art").query.description
                == #"query read planets filters=[planets[name] startswith "art"]"#
        )
        #expect(
            Planet.query(on: db)
                .filter(\.$name ~= "art").query.description
                == #"query read planets filters=[planets[name] endswith "art"]"#
        )

        // name doesn't contain string anywhere, prefix, suffix
        #expect(
            Planet.query(on: db)
                .filter(\.$name !~ "art").query.description
                == #"query read planets filters=[planets[name] !contains "art"]"#
        )
        #expect(
            Planet.query(on: db)
                .filter(\.$name !=~ "art").query.description
                == #"query read planets filters=[planets[name] !startswith "art"]"#
        )
        #expect(
            Planet.query(on: db)
                .filter(\.$name !~= "art").query.description
                == #"query read planets filters=[planets[name] !endswith "art"]"#
        )

        // name in array
        #expect(
            Planet.query(on: db)
                .filter(\.$name ~~ ["Earth", "Mars"]).query.description
                == #"query read planets filters=[planets[name] ~~ ["Earth", "Mars"]]"#
        )

        // name not in array
        #expect(
            Planet.query(on: db)
                .filter(\.$name !~ ["Earth", "Mars"]).query.description
                == #"query read planets filters=[planets[name] !~~ ["Earth", "Mars"]]"#
        )
    }
}

private final class Planet: Model, @unchecked Sendable {
    static let schema = "planets"

    @ID(custom: .id)
    var id: Int?

    @Field(key: "name")
    var name: String
}
