extension Value {
    public var isNull: Bool {
        return structuredData.isNull
    }

    public var bool: Bool? {
        return structuredData.bool
    }

    public var float: Float? {
        return structuredData.float
    }

    public var double: Double? {
        return structuredData.double
    }

    public var int: Int? {
        return structuredData.int
    }

    public var string: String? {
        return structuredData.string
    }

    public var array: [Polymorphic]? {
        return structuredData.array
    }

    public var object: [String: Polymorphic]? {
        return structuredData.object
    }
}
