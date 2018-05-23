/// Fluent's supported filter relation methods.
public protocol QueryFilterRelation {
    /// &&
    static var fluentAnd: Self { get }

    /// ||
    static var fluentOr: Self { get }
}
