public struct SchemaColumn {
    public var name: String
    public var dataType: String

    public init(
        name: String,
        dataType: String
    ) {
        self.name = name
        self.dataType = dataType
    }
}
