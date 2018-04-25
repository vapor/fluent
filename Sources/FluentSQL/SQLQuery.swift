public enum SQLQuery {
    case query(DataQuery)
    case manipulation(DataManipulationQuery)
    case definition(DataDefinitionQuery)
}

extension SQLSerializer {
    public func serialize(_ query: SQLQuery) -> String {
        switch query {
        case .definition(let d): return serialize(query: d)
        case .manipulation(let m): return serialize(query: m)
        case .query(let q): return serialize(query: q)
        }
    }
}
