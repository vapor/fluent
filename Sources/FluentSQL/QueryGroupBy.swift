import Fluent
import SQL

extension QueryGroupBy {
    /// Convert query group by to sql group by.
    internal func makeDataGroupBy() -> DataGroupBy {
        switch self {
        case .field(let field):
            return DataGroupBy.column(field.makeDataColumn())
        }
    }
}
