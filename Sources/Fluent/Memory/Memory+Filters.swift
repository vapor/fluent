extension Sequence where Iterator.Element == Node {
    func fails(_ f: Filter) -> [Node] {
        return filter { node in
            return !node.passes(f)
        }
    }

    func fails(_ filters: [Filter]) -> [Node] {
        var filtered: [Node] = Array(self)

        for f in filters {
            filtered = filtered.fails(f)
        }

        return filtered
    }

    func passes(_ f: Filter) -> [Node] {
        return filter { node in
            return node.passes(f)
        }
    }

    func passes(_ filters: [Filter]) -> [Node] {
        var filtered: [Node] = Array(self)

        for f in filters {
            filtered = filtered.passes(f)
        }

        return filtered
    }
}

extension Node {
    func passes(_ filters: [Filter]) -> Bool {
        for f in filters {
            if !passes(f) {
                return false
            }
        }
        return true
    }

    func passes(_ filter: Filter) -> Bool {
        switch filter.method {
        case .compare(let key, let comparison, let val):
            switch comparison {
            case .equals:
                if
                    let value = self[key]?.string,
                    let val = val.string,
                    val == value
                {
                    return true
                }

                return false
            case .contains:
                if let value = self[key]?.string,
                    let val = val.string,
                    value.contains(val) {

                    return true
                }
                return false
            case .greaterThan:
                if  let value = self[key]?.double,
                    let val = val.double,
                    value > val {

                    return true
                }
                return false
            case .greaterThanOrEquals:
                if let value = self[key]?.double,
                    let val = val.double,
                    value >= val {
                    return true
                }
                return false
            case .hasPrefix:
                if let value = self[key]?.string,
                    let val = val.string,
                    value.hasPrefix(val) {
                    return true
                }
                return false
            case .hasSuffix:
                if let value = self[key]?.string,
                    let val = val.string,
                    value.hasSuffix(val) {
                    return true
                }
                return false
            case .lessThan:
                if let value = self[key]?.double,
                    let val = val.double,
                    value < val {
                    return true
                }
                return false
            case .lessThanOrEquals:
                if let value = self[key]?.double,
                    let val = val.double,
                    value <= val {
                    return true
                }
                return false
            case .notEquals:
                if let value = self[key]?.string,
                    let val = val.string,
                    value != val {
                    return true
                }
                return false
            }
        case .subset(let key, let scope, let subset):
            switch scope {
            case .in:
                if let value = self[key],
                    subset.contains(value) {

                    return true
                }
            case .notIn:
                if let value = self[key],
                    !subset.contains(value) {

                    return true
                }
            }
        }
        return false

    }
}
