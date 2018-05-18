/// Supported database schema actions.
public protocol SchemaAction {
    static var fluentCreate: Self { get }
    static var fluentUpdate: Self { get }
    static var fluentDelete: Self { get }
}
