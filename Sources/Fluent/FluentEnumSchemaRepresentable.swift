import Foundation

/// A protocol that allows enums to provide a consistent Fluent field key and database enum name.
public protocol FluentEnumSchemaRepresentable: RawRepresentable, CaseIterable {
    /// The name used for the enum in the database (e.g. "day").
    static var fluentEnumName: String { get }
}

public extension FluentEnumSchemaRepresentable where RawValue == String {
    /// A `FieldKey` representing this enum's database field name.
    static var fieldKey: FieldKey {
        .init(unicodeScalarLiteral: fluentEnumName)
    }
}
