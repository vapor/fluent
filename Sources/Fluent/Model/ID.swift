import Core

/// A Fluent compatible identifier.
public protocol ID: Codable, Equatable { }

extension Int: ID { }
extension String: ID { }
extension UUID: ID { }
