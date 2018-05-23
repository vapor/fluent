public protocol QueryFilterMethod {
    static var fluentEqual: Self { get }
    static var fluentNotEqual: Self { get }
    static var fluentGreaterThan: Self { get }
    static var fluentLessThan: Self { get }
    static var fluentGreaterThanOrEqual: Self { get }
    static var fluentLessThanOrEqual: Self { get }
    static var fluentInSubset: Self { get }
    static var fluentNotInSubset: Self { get }
}
