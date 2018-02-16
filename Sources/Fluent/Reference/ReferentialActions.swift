/// Actions that will take place when a reference is modified.
public struct ReferentialActions {
    /// Action to take if referenced entities are updated.
    public var update: ReferentialAction?

    /// Action to take if referenced entities are deleted.
    public var delete: ReferentialAction?

    /// Creates a new `ReferentialActions`
    public init(update: ReferentialAction? = nil, delete: ReferentialAction? = nil) {
        self.update = update
        self.delete = delete
    }

    /// The default `ReferentialActions`
    public static let `default`: ReferentialActions = .init(update: nil, delete: nil)

    /// The default `ReferentialActions`
    public static let prevent: ReferentialActions = .init(update: .prevent, delete: .prevent)

    /// The default `ReferentialActions`
    public static let nullify: ReferentialActions = .init(update: .nullify, delete: .nullify)

    /// The default `ReferentialActions`
    public static let update: ReferentialActions = .init(update: .update, delete: .update)
}
