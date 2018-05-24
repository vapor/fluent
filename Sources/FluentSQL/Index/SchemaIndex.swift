//extension Schema where Database: IndexSupporting {
//    /// An index on fields on the schema.
//    ///
//    /// Indexes can apply to one or more fields and may increase
//    /// the performance of database fetches when filtering on the fields.
//    ///
//    /// If the index is specified to be unique, the database engine is expected
//    /// to prevent creation of data where it already exists.
//    ///
//    /// Use `SchemaBuilder` to add and remove indexes on an `IndexSupporting` database.
//    ///
//    ///     builder.addIndex(to: \.username, isUnique: true)
//    ///
//
//
//    /// Field indexes that should be added for this schema.
//    public var addIndexes: [Index] {
//        get { return extend.get(\Schema<Database>.addIndexes, default: []) }
//        set { extend.set(\Schema<Database>.addIndexes, to: newValue) }
//    }
//
//    /// Field indexes that should be removed for this schema.
//    public var removeIndexes: [Index] {
//        get { return extend.get(\Schema<Database>.removeIndexes, default: []) }
//        set { extend.set(\Schema<Database>.removeIndexes, to: newValue) }
//    }
//}
