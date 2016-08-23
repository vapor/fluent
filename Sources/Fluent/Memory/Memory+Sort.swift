extension Sequence where Iterator.Element == Node {
    func sort(_ sort: Sort) -> [Node] {
        return sorted { first, second in
            guard
                let f1 = first[sort.field]?.string,
                let f2 = second[sort.field]?.string
            else {
                    return false
            }
            switch sort.direction {
            case .ascending:
                return f1 < f2
            case .descending:
                return f1 > f2
            }
        }
    }

    func sort(_ sorts: [Sort]) -> [Node] {
        var data = Array(self)

        for sort in sorts {
            data = data.sort(sort)
        }

        return data
    }
}
