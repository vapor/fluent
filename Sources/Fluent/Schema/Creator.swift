/// A schema builder for creating schema
public final class Creator: Builder {
    /// The fields to be created
    public var fields: [RawOr<Field>]
    
    /// The foreign keys to be created
    public var foreignKeys: [RawOr<ForeignKey>]
    
    /// Creates a new schema creator
    public init() {
        fields = []
        foreignKeys = []
    }
}
