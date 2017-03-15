public enum Raw {
    case filter(String, [Node])
    case join(String)
    case limit(String)
    case sort(String)
}

extension Raw {
    public init(
        filter: String,
        values: [NodeRepresentable] = []
    ) throws {
        let values = try values.map { nr in
            return try nr.makeNode(in: nil)
        }
        self = .filter(filter, values)
    }
}

extension Sequence where Iterator.Element == Raw {
    /// All raw filters and values
    public var filters: [(String, [Node])] {
        return flatMap { raw in
            guard case .filter(let string, let values) = raw else {
                return nil
            }
            return (string, values)
        }
    }

    /// All raw joins
    public var joins: [String] {
        return flatMap { raw in
            guard case .join(let string) = raw else {
                return nil
            }
            return string
        }
    }

    /// All raw limits
    public var limits: [String] {
        return flatMap { raw in
            guard case .limit(let string) = raw else {
                return nil
            }
            return string
        }
    }

    /// All raw sorts
    public var sorts: [String] {
        return flatMap { raw in
            guard case .sort(let string) = raw else {
                return nil
            }
            return string
        }
    }
}
