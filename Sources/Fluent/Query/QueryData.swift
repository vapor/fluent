/// Fluent-compatible query data.
public protocol QueryData {
    /// Creates an instance of self from an `Encodable` object.
    static func fluentEncodable(_ encodable: Encodable) -> Self
}
