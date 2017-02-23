import SQLite

/**
    SQLite-specific overrides for the GeneralSQLSerializer
  */
public class SQLiteSerializer: GeneralSQLSerializer {
    /**
        Serializes a SQLite data type.
      */
    public override func sql(_ type: Schema.Field.DataType, primaryKey: Bool) -> String {
        // SQLite has a design where any data type that does not contain `TEXT`,
        // `CLOB`, or `CHAR` will be treated with `NUMERIC` affinity.
        // All SQLite `STRING` fields should instead be declared with `TEXT`.
        // More information: https://www.sqlite.org/datatype3.html
        if case .string(_)  = type {
            return "TEXT"
        }

        return super.sql(type, primaryKey: primaryKey)
    }
}
