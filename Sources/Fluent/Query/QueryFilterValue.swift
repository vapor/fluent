/// Fluent's supported filter values.
public protocol QueryFilterValue: PropertySupporting {
    /// One or more bound values (added to the binds array).
    static func fluentBind(_ count: Int) -> Self

    /// Special case: nil value. No binds added.
    static var fluentNil: Self { get }
}
