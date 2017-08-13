/// Box struct, use this type for blob columns in Models
struct Blob {
    var bytes: [UInt8]
}

extension Blob: NodeRepresentable {
    func makeNode(in context: Context?) throws -> Node {
        return Node.bytes(bytes, in: context)
    }
}

extension Blob: NodeInitializable {
    init(node: Node) throws {
        guard let bytes = node.bytes else {
            throw NodeError.unableToConvert(input: node, expectation: "[UInt8]", path: [])
        }

        self.bytes = bytes
    }
}
