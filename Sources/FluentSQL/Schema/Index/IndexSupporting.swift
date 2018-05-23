///// Defines database types that support indexes.
/////
///// Conforming to this protocol adds properties to `DatabaseSchema` for storing
///// index operations: `addIndexes` and `removeIndexes`. Databases conforming to this
///// protocol are expected to respect any `SchemaIndex`s supplied in those properties.
/////
/////     print(databaseSchema.addIndexes) // [SchemaIndex<D>]
/////
///// `SchemaBuilder`s created on `IndexSupporting` databases will have additional methods
///// for interacting with the index properties on `DatabaseSchema`: `addIndex` and `removeIndex`.
/////
/////     PostgreSQLDatabase.create(...) { builder in
/////         ...
/////         builder.addIndex(to: \.username, isUnique: true)
/////     }
/////
//public protocol IndexSupporting: SchemaSupporting { }
