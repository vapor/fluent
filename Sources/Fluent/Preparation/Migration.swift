final class Migration: Model {
    static var entity = "fluent"

    var id: Value?
    var name: String

    init(name: String) {
        self.name = name
    }

    init(serialized: [String: Value]) {
        id = serialized["id"]
        name = serialized["name"]?.string ?? ""
    }
}
