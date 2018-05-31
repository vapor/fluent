/// A Fluent compatible identifier. See `Model`.
public protocol ID: Codable, Equatable { }

// MARK: Default conformances

extension Int: ID { }
extension String: ID { }
extension UUID: ID { }
