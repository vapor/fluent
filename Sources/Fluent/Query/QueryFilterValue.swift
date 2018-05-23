public protocol QueryFilterValue: PropertySupporting {
    static func fluentBind(_ count: Int) -> Self
    static var fluentNil: Self { get }
}
