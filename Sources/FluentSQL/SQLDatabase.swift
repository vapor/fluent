public protocol SQLDatabase: SchemaSupporting & JoinSupporting where Query: SQLQuery, Schema: SQLSchema { }
