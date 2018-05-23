public protocol SQLDatabase: SchemaSupporting where Query: SQLQuery, Schema: SQLSchema { }
