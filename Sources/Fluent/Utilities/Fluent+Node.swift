@_exported import Node

//public enum ExtractionError: Error {
//    case unexpectedNil
//    case invalidType
//}
//
//extension Node {
//    public func extract(_ key: PathIndex) throws -> Node {
//        guard let node = self[key] else {
//            throw ExtractionError.unexpectedNil
//        }
//
//        return node
//    }
//
//    public func extract<N: NodeInitializable>(_ key: PathIndex) throws -> N {
//        guard let node = self[key] else {
//            throw ExtractionError.unexpectedNil
//        }
//
//        return try N(: node)
//    }
//
//
//    public func extract<N: NodeInitializable>(_ key: PathIndex) throws -> [N] {
//        guard let node = self[key]?.nodeArray else {
//            throw ExtractionError.unexpectedNil
//        }
//
//        return try [N](with: node)
//    }
//}
