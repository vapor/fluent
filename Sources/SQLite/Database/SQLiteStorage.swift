/// Available SQLite storage methods.
public enum SQLiteStorage {
    case memory
    case file(path: String)
}
