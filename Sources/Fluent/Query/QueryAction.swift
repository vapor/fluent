public protocol QueryAction {
    static var fluentCreate: Self { get }
    static var fluentRead: Self { get }
    static var fluentUpdate: Self { get }
    static var fluentDelete: Self { get }
    var fluentIsCreate: Bool { get }
}
