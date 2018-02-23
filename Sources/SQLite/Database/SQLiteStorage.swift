/// Available SQLite storage methods.
public enum SQLiteStorage {
    case memory
    case file(path: String)

    var path: String {
        switch self {
        case .memory: return "/tmp/_swift-tmp.sqlite"
        case .file(let path): return path
        }
    }
}
