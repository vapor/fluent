/// Represents the databases currently configured for Fluent.
public struct Databases {
    /// Internal storage: [DatabaseIdentifier: Database]
    private let storage: [String: Any]

    /// Creates a new Databases struct.
    internal init(_ storage: [String: Any]) {
        self.storage = storage
    }

    /// Fetches the database for a given ID.
    public func database<D>(for id: DatabaseIdentifier<D>) -> D? {
        return storage[id.uid] as? D
    }
}
