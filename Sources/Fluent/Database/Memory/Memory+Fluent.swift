
import Foundation

extension Memory {
    public func register(item name: String, metadata: Metadata = Metadata()) throws {
        guard self[name] == nil else {
            throw MemoryError.itemExistAlready(name)
        }
        
        var store = [String: Node]()
        store[Metadata.key] = try metadata.makeNode()
        self[name] = Node(store)
    }
    
    public func store(item name: String, data: Node, idKey: String = "id") throws {
        if self[name] == nil {
            try register(item: name)
        }
        
        guard var mem = self[name] else {
            return
        }
        
        let meta = try Metadata(node: mem[Metadata.key])
        meta.increment += 1
        meta.lastUpdatedDate = Date()
        
        mem["\(meta.increment)"] = data
        mem[Metadata.key] = try meta.makeNode()
        
        self[name] = mem
        
    }
    
    public func recall(item name: String, filters: [Fluent.Filter]? = nil, idKey: String = "id") throws -> Node {
        //        guard let node = self[name] else {
        //            throw MemoryError.itemDoesNotExist
        //        }
        //
        //        guard case .array(let _) = node else {
        //            return .null
        //        }
        
        
        /// TODO find my item
        return .null
    }
    
    public func update(item name: String, data: Node, idKey: String = "id", filter: Fluent.Filter) throws {
        guard var mem = self[name],
              let dataId = data[idKey]?.string,
              let memId = mem[idKey]?.string,
              memId == dataId else {
            return
        }
        
        mem[idKey] = data
    }
    
    public func removeItem(with name: String, at index: Int) throws {
        guard var mem = self[name]?.object else {
                throw MemoryError.itemDoesNotExist(name)
        }
        
        mem.removeValue(forKey: "\(index)")
    }
    
    public func remove(item name: String) throws {
        self.store.removeValue(forKey: name)
    }
}

extension Memory: CustomStringConvertible {
    public var description: String {
        return "In memory ...\n\(self.store)"
    }
}

public enum MemoryError: Error {
    case itemExistAlready(String)
    case itemDoesNotExist(String)
    case incompatibleNodeType
    case missingIdKey
    case missingMetadata
}
