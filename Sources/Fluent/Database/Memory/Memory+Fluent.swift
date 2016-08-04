import Node
import Foundation

extension Memory {
    public func make(_ name: String, metadata: Metadata = Metadata()) throws {
        guard self[name] == nil else {
            throw MemoryError.doesExistAlready(name)
        }
        
        var obj = [String: Node]()
        obj[Metadata.key] = try metadata.makeNode()
        self[name] = Node(obj)
    }
    
    public func set(_ name: String, data: Node, idKey: String = "id") throws {
        if self[name] == nil {
            try make(name)
        }
        
        guard var obj = self[name] else {
            return
        }
        
        let metadata = try Metadata(with: obj[Metadata.key]!)
        metadata.increment += 1
        metadata.lastUpdatedDate = Date()
        
        obj["\(metadata.increment)"] = data
        obj[Metadata.key] = try metadata.makeNode()
        
        self[name] = obj
        
    }
    
    public func get(_ name: String, filters: [Fluent.Filter]? = nil, idKey: String = "id") throws -> Node {
        return .null
    }
    
    public func update(_ name: String, data: Node, idKey: String = "id", filter: Fluent.Filter) throws {
        guard var obj = self[name],
            let dataId = data[idKey]?.string,
            let objId = obj[idKey]?.string,
            objId == dataId else {
                return
        }
        
        obj[idKey] = data
    }
    
    public func remove(_ name: String, at index: Int) throws {
        guard var obj = self[name]?.object else {
            throw MemoryError.doesNotExist(name)
        }
        
        obj.removeValue(forKey: "\(index)")
    }
    
    public func remove(_ name: String) throws {
        self.store.removeValue(forKey: name)
    }
}

extension Memory: CustomStringConvertible {
    public var description: String {
        return "In memory ...\n\(self.store)"
    }
}

public enum MemoryError: Error {
    case doesExistAlready(String)
    case doesNotExist(String)
    case incompatibleNodeType
    case missingIdKey
    case missingMetadata
}
