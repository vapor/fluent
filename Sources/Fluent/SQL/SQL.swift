public enum SQL {
    public enum TableAction {
        case create(columns: [Column])
        case alter(create: [Column], delete: [String])
        case drop
    }

    public enum Column {
        case primaryKey
        case integer(String)
        case string(String, Int?)
    }

    case insert(table: String, data: [String: Value])
    case select(table: String, filters: [Filter], limit: Int?)
    case update(table: String, filters: [Filter], data: [String: Value])
    case delete(table: String, filters: [Filter], limit: Int?)
    case table(action: TableAction, table: String)
}
