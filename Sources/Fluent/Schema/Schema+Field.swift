extension Schema {
    /**
        Various types of fields
        that can be used in a Schema.
    */
    public enum Field {
        case id
        case int(String)
        case string(String, length: Int?)
        case double(String, digits: Int?, decimal: Int?)
    }
}
