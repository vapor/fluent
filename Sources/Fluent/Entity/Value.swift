/**
    A type of data that can be retrieved
    or stored in a database.
*/
public enum Node {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case data([UInt8])
    case array([Node])
    case dictionary([String: Node])
    case null
}

extension Node: NodeRepresentable {
    public init(_ node: Node) throws {
        self = node
    }

    public func makeNode() -> Node {
        return self
    }
}

extension Node: Polymorphic {
    public var isNull: Bool {
        return false
    }

    public var bool: Bool? {
        guard case .bool(let bool) = self else {
            return nil
        }

        return bool
    }

    public var float: Float? {
        return nil
    }

    public var double: Double? {
        switch self {
        case .int(let int):
            return Double(int)
        case .double(let double):
            return double
        case .string(let string):
            return Double(string)
        default:
            return nil
        }
    }

    public var int: Int? {
        switch self {
        case .int(let int):
            return int
        case .double(let double):
            return Int(double)
        case .string(let string):
            return Int(string)
        default:
            return nil
        }
    }

    public var string: String? {
        switch self {
        case .string(let string):
            return string
        case .int(let int):
            return int.description
        default:
            return nil
        }
    }

    public var array: [Polymorphic]? {
        return nil
    }

    public var object: [String : Polymorphic]? {
        return nil
    }


    public init(_ representable: NodeRepresentable) {
        self = representable.makeNode()
    }

    public init(_ representable: NodeRepresentable?) {
        self = representable?.makeNode() ?? .null
    }

    public init(_ representable: [NodeRepresentable]) {
        var node: [Node] = []

        for (representable) in representable {
            node.append(Node(representable))
        }

        self = .array(node)
    }

    public init(_ representable: [NodeRepresentable?]) {
        var node: [Node] = []

        for (representable) in representable {
            node.append(Node(representable))
        }

        self = .array(node)
    }

    public init(_ representable: [String: NodeRepresentable]) {
        var node: [String: Node] = [:]

        for (key, representable) in representable {
            node[key] = Node(representable)
        }

        self = .dictionary(node)
    }

    public init(_ representable: [String: NodeRepresentable?]) {
        var node: [String: Node] = [:]

        for (key, representable) in representable {
            node[key] = Node(representable)
        }

        self = .dictionary(node)
    }
}

public enum ExtractionError: ErrorProtocol {
    case notDictionary
    case invalidType
}

public protocol NodeInitializable {
    init(_ node: Node) throws
}

public protocol NodeRepresentable {
    func makeNode() -> Node
}

public protocol NodeConvertible: NodeInitializable, NodeRepresentable {}

extension Int: NodeRepresentable {
    public func makeNode() -> Node {
        return .int(self)
    }
}

extension String: NodeRepresentable {
    public func makeNode() -> Node {
        return .string(self)
    }
}

extension Bool: NodeRepresentable {
    public func makeNode() -> Node {
        return .bool(self)
    }
}

extension NodeInitializable {
    public init(_ representable: [NodeRepresentable]) throws {
        let node = Node(representable)
        try self.init(node)
    }

    public init(_ representable: [String: NodeRepresentable]) throws {
        let node = Node(representable)
        try self.init(node)
    }
}

extension Node {
    public func extract(_ key: String) throws -> Int {
        guard case .dictionary(let dict) = self else {
            throw ExtractionError.notDictionary
        }

        guard let int = dict[key]?.int else {
            print("\(key) not Int")
            throw ExtractionError.invalidType
        }

        return int
    }

    public func extract(_ key: String) throws -> String {
        guard case .dictionary(let dict) = self else {
            throw ExtractionError.notDictionary
        }

        guard let string = dict[key]?.string else {
            print("\(key) not String. \(dict)")
            throw ExtractionError.invalidType
        }

        return string
    }

    public func extract(_ key: String) throws -> Node {
        guard case .dictionary(let dict) = self else {
            throw ExtractionError.notDictionary
        }

        guard let node = dict[key] else {
            print("\(key) not Node")
            throw ExtractionError.invalidType
        }

        return node
    }
}
