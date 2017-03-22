/// Modifies a schema. A subclass of Creator.
/// Can modify or delete fields.
public final class Modifier: Builder {
    public var fields: [RawOr<Field>]
    public var delete: [RawOr<Field>]

    public init() {
        fields = []
        delete = []
    }

    public func delete(_ name: String) {
        let field = Field(
            name: name,
            type: .custom(type: "delete")
        )
        delete.append(.some(field))
    }
}
