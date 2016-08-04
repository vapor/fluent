
import Foundation
import Node

public final class Metadata: NodeConvertible {
    public var increment: Int = -1
    public var version: String = "0.0.0"
    public var creationDate: Date = Date()
    public var lastUpdatedDate: Date = Date()
    
    static var key: String = "__metadata"
    public init() {}
    
    public init(node: Node, in context: Context) throws {
        self.increment = try node.extract("increment")
        self.version = try node.extract("version")
        self.lastUpdatedDate =  Date(timeIntervalSinceNow: try node.extract("lastUpdatedDate"))
        self.creationDate = Date(timeIntervalSinceNow: try node.extract("creationDate"))
        
    }
    
    public func makeNode() throws -> Node {
        return Node([
            "increment": Node(self.increment),
            "version": Node(self.version),
            "creationDate": Node(self.creationDate.timeIntervalSinceNow),
            "lastUpdatedDate": Node(self.lastUpdatedDate.timeIntervalSinceNow)
            ])
    }
}
