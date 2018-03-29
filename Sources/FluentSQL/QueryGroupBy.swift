import Fluent
import SQL

extension QueryGroupBy {
    /// Convert query group by to sql group by.
    internal func makeDataGroupBy() -> DataGroupBy {
        guard let field = field() else {
            return DataGroupBy.column("false")
        }
        return DataGroupBy.column(field.makeDataColumn())
    }
}
