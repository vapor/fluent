import Foundation
import Node

public final class Metadata: NodeConvertible {
    public var increment: Int = -1
    public var version: String = "0.0.0"
    public var creationDate: Date = Date()
    public var lastUpdatedDate: Date = Date()
    
    public static var key: String = "__metadata"
    public init() {}
    
    public init(node: Node, in context: Context) throws {
        self.increment = try node.extract("increment")
        self.version = try node.extract("version")
        self.lastUpdatedDate =  Date(timeIntervalSinceNow: try node.extract("lastUpdatedDate"))
        self.creationDate = Date(timeIntervalSinceNow: try node.extract("creationDate"))
        
    }
    
    public func makeNode() throws -> Node {
        return try Node(node: [
            "increment": self.increment,
            "version": self.version,
            "creationDate": self.creationDate.timeIntervalSinceNow,
            "lastUpdatedDate": self.lastUpdatedDate.timeIntervalSinceNow
            ])
    }
}
