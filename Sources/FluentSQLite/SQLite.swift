#if os(Linux)
	import CSQLiteLinux
#else
	import CSQLiteMac
#endif

let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

public class SQLite {
    typealias PrepareClosure = ((SQLite) throws -> ())

    private var statementPointer: UnsafeMutablePointer<OpaquePointer?>! = nil
    private var statement: OpaquePointer {
        return statementPointer.pointee!
    }

	var database: OpaquePointer?

    var bindPosition: Int32 = 0
    
    var nextBindPosition: Int32 {
        bindPosition += 1
        return bindPosition
    }

	init(path: String) throws {
        let options = SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX
        if sqlite3_open_v2(path, &database, options, nil) != SQLITE_OK {
            sqlite3_close(database)
            throw Error.connection(errorMessage)
        }
	}

    public enum Error: ErrorProtocol {
        case connection(String)
        case close(String)
        case prepare(String)
        case bind(String)
        case execute(String)
    }

	func close() {
        sqlite3_close(database)
	}

	struct Result {
		struct Row {
			var data: [String: String]

			init() {
				data = [:]
			}
		}

		var rows: [Row]

		init() {
			rows = []
		}
	}

    func execute(_ queryString: String, prepareClosure: PrepareClosure = { _ in }) throws -> [Result.Row] {
        bindPosition = 0
        statementPointer = UnsafeMutablePointer<OpaquePointer?>.init(allocatingCapacity: 1)

        if sqlite3_prepare_v2(database, queryString, -1, statementPointer, nil) != SQLITE_OK {
            throw Error.prepare(errorMessage)
        }

        try prepareClosure(self)

        var result = Result()
        while sqlite3_step(statement) == SQLITE_ROW {
            
            var row = Result.Row()
            let count = sqlite3_column_count(statement)

            for i in 0..<count {
                let text = sqlite3_column_text(statement, i)
                let name = sqlite3_column_name(statement, i)

                let value = String(cString: UnsafePointer(text))
                let column = String(cString: name)

                row.data[column] = value
            }

            result.rows.append(row)
        }
        
        if sqlite3_finalize(statement) != SQLITE_OK {
            throw Error.execute(errorMessage)
        }
        
        return result.rows
    }

    var lastId: Int {
        let id = sqlite3_last_insert_rowid(database)
        return Int(id)
    }
    
    var errorMessage: String {
        let raw = sqlite3_errmsg(database)

        return String(cString: raw) ?? ""
    }
    
    func reset(_ statementPointer: OpaquePointer) {
        sqlite3_reset(statementPointer)
        sqlite3_clear_bindings(statementPointer)
    }

    func bind(_ value: Double) throws {
        if sqlite3_bind_double(statementPointer.pointee, nextBindPosition, value) != SQLITE_OK {
            throw Error.bind(errorMessage)
        }
    }

    func bind(_ value: Int) throws {
        if sqlite3_bind_int(statementPointer.pointee, nextBindPosition, Int32(value)) != SQLITE_OK {
            throw Error.bind(errorMessage)
        }
    }

    func bind(_ value: String) throws {
        let strlen = Int32(value.characters.count)
        if sqlite3_bind_text(statementPointer.pointee, nextBindPosition, value, strlen, SQLITE_TRANSIENT) != SQLITE_OK {
            throw Error.bind(errorMessage)
        }
    }

    func bind(_ value: Bool) throws {
        try bind(value ? 1 : 0)
    }

}
