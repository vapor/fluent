public enum SQL {
    public enum TableAction {
        case create, alter
    }

    public enum Column {
        case integer(String)
        case string(String, Int)
    }

    case insert(table: String, data: [String: Value])
    case select(table: String, filters: [Filter], limit: Int?)
    case update(table: String, filters: [Filter], data: [String: Value])
    case delete(table: String, filters: [Filter], limit: Int?)
    case table(action: TableAction, table: String, columns: [Column])
}
