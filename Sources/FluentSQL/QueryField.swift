import Fluent
import SQL

public protocol DataColumnRepresentable {
    func makeDataColumn() -> DataColumn
}
