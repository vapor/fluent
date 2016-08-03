import Node
import Foundation

extension Memory {
    public func register(item name: String, metadata: Metadata = Metadata()) throws {
        guard self[name] == nil else {
            throw MemoryError.itemExistAlready
        }

        self[name] = .array([])

        guard let node = self[name],
              case .array(var items) = node else {
            return
        }
        
        items.append(.object(["metadata": try! metadata.makeNode()]))
        
        self[name] = .array(items)
        
        print("Created item \(name) in memory with metadata \(metadata)")
    }
    
    public func store(item name: String, data: Node, idKey: String = "id") throws {
        if self[name] == nil {
            try register(item: name)
        }
        
        guard let node = self[name],
              case .array(var items) = node else {
            throw MemoryError.itemDoesNotExist
        }

        guard case .object(var dict) = data else {
            throw MemoryError.incompatibleNodeType // should only be object node type??
        }

        let meta = try metadata(forItem: name)
        meta.increment += 1
        
        if dict[idKey] == nil { // don't have id make one
            dict[idKey] = .string("\(meta.increment)")
        }

        guard let dictNode =  dict[idKey],
              case .string(let id) = dictNode else {
            throw MemoryError.invalidIdKey // this should never happen
        }
        
        items.append(.object(["\(id)": data]))
        self[name] = .array(items)
        print("stored with id \(id):\n\(data) into \(name)")
    
    }
    
    internal func metadata(forItem name: String) throws -> Metadata {
        guard let node = self[name],
              case .array(let arr) = node else {
            throw MemoryError.missingMetadata
        }
        
        for n in arr {
            guard case .object(let obj) = n else {
                continue
            }
            
            if obj["metadata"] != nil {
                return try Metadata(with: obj["metadata"]!)
            }
        }
        
        throw MemoryError.missingMetadata
    }
    
    public func recall(item name: String, filters: [Filter]? = nil) throws -> Node {
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
    
    public func update(item name: String, data: Node?) throws {
//        guard let node = self[name] else {
//            throw MemoryError.itemDoesNotExist
//        }
//        
//        guard let node = self[name],
//            case .array(var items) = node else {
//                throw MemoryError.itemDoesNotExist
//        }
//        
//        for item in items {
//            guard case .object(var dict) = data else {
//                continue
//            }
//            
//            guard let dictNode =  dict[idKey],
//                case .string(let id) = dictNode else {
//                    
//            }
//        }
    }
    
    public func remove(item name: String) throws {
        self.store.removeValue(forKey: name)
    }
}

extension Memory: CustomStringConvertible {
    public var description: String {
        return "Items in memory:\n\(self.store)"
    }
}

public enum MemoryError: Error {
    case itemExistAlready
    case itemDoesNotExist
    case incompatibleNodeType
    case invalidIdKey
    case missingMetadata
}
