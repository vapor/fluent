import CodableKit
import Foundation


/// A Fluent compatible identifier.
public protocol ID: Codable, Equatable, KeyStringDecodable { }

extension Int: ID { }
extension String: ID { }
extension UUID: ID { }
