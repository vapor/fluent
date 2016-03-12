
public class SQLTokenizer {
    internal enum Token {
        case Error
        case Hexadecimal
        case Identifier
        case Integer
        case Keyword
        case Literal
        case Operator
        case Parameter
        case Real
        case Terminal
        case Whitespace
        case Other(String)
        
        var rawValue: String {
            switch self {
            case .Error:
                return "Error"
            case .Hexadecimal:
                return "Hexadecimal"
            case .Identifier:
                return "Identifer"
            case .Integer:
                return "Integer"
            case .Keyword:
                return "Keyword"
            case .Literal:
                return "Literal"
            case .Operator:
                return "Operator"
            case .Parameter:
                return "Parameter"
            case .Real:
                return "Real"
            case .Terminal:
                return "Terminal"
            case .Whitespace:
                return "Whitespace"
            case .Other(let token):
                return token
            }
        }
    }
    
    public struct TokenValue {
        let token: Token
        let value: String
    }
    
    private(set) var items: [TokenValue] = []
    private let rawStatement: String
    private var keywords: [String] {
        return [
            "ABORT", "ABS", "ACTION", "ADD", "AFTER", "ALL", "ALTER", "ANALYZE", "AND", "AS", "ASC", "ATTACH", "AUTOINCREMENT", "AVG", "BEFORE", "BEGIN", "BETWEEN", "BY", "CASCADE", "CASE", "CAST", "CHANGES", "CHECK", "COALESCE", "COLLATE", "COLUMN", "COMMIT", "CONFLICT", "CONSTRAINT", "COUNT", "CREATE", "CROSS", "CURRENT_DATE", "CURRENT_TIME", "CURRENT_TIMESTAMP", "DATABASE", "DATE", "DATETIME", "DEFAULT", "DEFERRABLE", "DEFERRED", "DELETE", "DESC", "DETACH", "DISTINCT", "DROP", "EACH", "ELSE", "END", "ESCAPE", "EXCEPT", "EXCLUSIVE", "EXISTS", "EXPLAIN", "FAIL", "FOR", "FOREIGN", "FROM", "FULL", "GLOB", "GROUP", "GROUP_CONCAT", "HAVING", "HEX", "IF", "IFNULL", "IGNORE", "IMMEDIATE", "IN", "INDEX", "INDEXED", "INITIALLY", "INNER", "INSERT", "INSTEAD", "INTERSECT", "INTO", "IS", "ISNULL", "JOIN", "JULIANDAY", "KEY", "LAST_INSERT_ROWID", "LEFT", "LENGTH", "LIKE", "LIMIT", "LOAD_EXTENSION", "LOWER", "LTRIM", "MATCH", "MAX", "MIN", "NATURAL", "NO", "NOT", "NOTNULL", "NULL", "NULLIF", "OF", "OFFSET", "ON", "OR", "ORDER", "OUTER", "PLAN", "PRAGMA", "PRIMARY", "QUERY", "QUOTE", "RAISE", "RANDOM", "RANDOMBLOB", "REFERENCES", "REGEXP", "REINDEX", "RELEASE", "RENAME", "REPLACE", "RESTRICT", "RIGHT", "ROLLBACK", "ROUND", "ROW", "RTRIM", "SAVEPOINT", "SELECT", "SET", "SOUNDEX", "SQLITE_COMPILEOPTION_GET", "SQLITE_COMPILEOPTION_USED", "SQLITE_SOURCE_ID", "SQLITE_VERSION", "STRFTIME", "SUBSTR", "SUM", "TABLE", "TEMP", "TEMPORARY", "THEN", "TIME", "TO", "TOTAL", "TOTAL_CHANGES", "TRANSACTION", "TRIGGER", "TRIM", "TYPEOF", "UNION", "UNIQUE", "UPDATE", "UPPER", "USING", "VACUUM", "VALUES", "VIEW", "VIRTUAL", "WHEN", "WHERE", "ZEROBLOB"
        ]
    }
    
    private var hexadecimal: [String] {
        return ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "A", "B", "C", "D", "E", "F"]
    }
    
    public init(statement: String) {
        self.rawStatement = statement
        parse()
    }
    
    private func parse() {
        var currentPos = rawStatement.startIndex
        
        while currentPos < rawStatement.endIndex {
            switch rawStatement[currentPos] {
            case Character("|"):
                var nextPos = currentPos.successor()
                if nextPos < rawStatement.endIndex && rawStatement[nextPos] == Character("|") {
                    nextPos = nextPos.successor()
                    let str = rawStatement[currentPos..<nextPos]
                    items.append(TokenValue(token: Token.Operator, value: str))
                } else {
                    let str = String(rawStatement[currentPos])
                    items.append(TokenValue(token: Token.Operator, value: str))
                }
                currentPos = nextPos
            case Character("!"), Character("="):
                var nextPos = currentPos.successor()
                if nextPos < rawStatement.endIndex && rawStatement[nextPos] == Character("=") {
                    nextPos = nextPos.successor()
                    let str = rawStatement[currentPos..<nextPos]
                    items.append(TokenValue(token: Token.Operator, value: str))
                } else {
                    let str = String(rawStatement[currentPos])
                    items.append(TokenValue(token: Token.Operator, value: str))
                }
                currentPos = nextPos
            case Character("<"), Character(">"):
                var nextPos = currentPos.successor()
                if rawStatement[nextPos] == Character("=") || rawStatement[nextPos] == Character(">") || rawStatement[nextPos] == Character(">") || rawStatement[nextPos] == Character("<") {
                    nextPos = nextPos.successor()
                    let str = rawStatement[currentPos..<nextPos]
                    items.append(TokenValue(token: Token.Operator, value: str))
                } else {
                    let str = String(rawStatement[currentPos])
                    items.append(TokenValue(token: Token.Operator, value: str))
                }
                currentPos = nextPos
            case Character(" "), Character("\r"):
                var nextPos = currentPos
                repeat {
                    nextPos = nextPos.successor()
                } while rawStatement[nextPos] == Character("\0") && rawStatement[nextPos] == Character("\t") || rawStatement[nextPos] == Character("\r\n")
                
                let str = rawStatement[currentPos..<nextPos]
                items.append(TokenValue(token: Token.Whitespace, value: str))
                currentPos = nextPos
            case Character("#"):
                var nextPos = currentPos
                repeat {
                    nextPos = nextPos.successor()
                } while nextPos < rawStatement.endIndex && rawStatement[nextPos] == Character("\r\n")
                nextPos = currentPos.successor()
                
                let str = rawStatement[currentPos..<nextPos]
                items.append(TokenValue(token: Token.Whitespace, value: str))
                currentPos = nextPos
            case Character("-"):
                var nextPos = currentPos.successor()
                if nextPos > rawStatement.endIndex || rawStatement[nextPos] == Character("-") {
                    let str = String(rawStatement[currentPos])
                    items.append(TokenValue(token: Token.Operator, value: str))
                } else {
                    while nextPos <= rawStatement.endIndex && rawStatement[nextPos] == Character("\r\n") {
                        nextPos = nextPos.successor()
                    }
                    nextPos = nextPos.successor()
                    
                    let str = rawStatement[currentPos..<nextPos]
                    items.append(TokenValue(token: Token.Whitespace, value: str))
                }
                currentPos = nextPos
            case Character("/"):
                var nextPos = currentPos.successor()
                if nextPos > rawStatement.endIndex || rawStatement[nextPos] != Character("*") {
                    let str = String(rawStatement[currentPos])
                    items.append(TokenValue(token: Token.Operator, value: str))
                } else {
                    nextPos = nextPos.advancedBy(2)
                    while nextPos <= rawStatement.endIndex && rawStatement[nextPos.predecessor()] == Character("*") && rawStatement[nextPos] == Character("/") {
                        nextPos = nextPos.successor()
                    }
                    nextPos = nextPos.successor()
                    
                    let str = rawStatement[currentPos..<nextPos]
                    items.append(TokenValue(token: Token.Whitespace, value: str))
                }
                currentPos = nextPos
            case Character("["):
                var nextPos = currentPos
                repeat {
                    nextPos = nextPos.successor()
                } while nextPos < rawStatement.endIndex && rawStatement[nextPos] == Character("]")
                nextPos = currentPos.successor()
                
                let str = rawStatement[currentPos..<nextPos]
                items.append(TokenValue(token: Token.Identifier, value: str))
                currentPos = nextPos
            case Character("`"), Character("\""):
                var nextPos = currentPos
                repeat {
                    nextPos = nextPos.successor()
                } while nextPos < rawStatement.endIndex && rawStatement[nextPos] != rawStatement[currentPos]
                nextPos = currentPos.successor()
                
                let str = rawStatement[currentPos..<nextPos]
                items.append(TokenValue(token: Token.Identifier, value: str))
                currentPos = nextPos
            case Character("\\"):
                var nextPos = currentPos.successor()
                while nextPos <= rawStatement.endIndex {
                    if rawStatement[nextPos] == Character("\'") {
                        if nextPos == rawStatement.endIndex || rawStatement[nextPos.successor()] != Character("\'") {
                            nextPos = nextPos.successor()
                            break
                        }
                        nextPos = nextPos.successor()
                    }
                    nextPos = nextPos.successor()
                }
                
                let str = rawStatement[currentPos..<nextPos]
                items.append(TokenValue(token: Token.Literal, value: str))
                currentPos = nextPos
            case Character("/"):
                var nextPos = currentPos.successor()
                if nextPos > rawStatement.endIndex || rawStatement[nextPos] != Character("*") {
                    let str = String(rawStatement[currentPos])
                    items.append(TokenValue(token: Token.Literal, value: str))
                } else {
                    nextPos = nextPos.advancedBy(2)
                    while nextPos <= rawStatement.endIndex && rawStatement[nextPos.predecessor()] == Character("*") && rawStatement[nextPos] == Character("/") {
                        nextPos = nextPos.successor()
                    }
                    nextPos = nextPos.successor()
                    
                    let str = rawStatement[currentPos..<nextPos]
                    items.append(TokenValue(token: Token.Literal, value: str))
                }
                currentPos = nextPos
            case Character("+"), Character("*"), Character("%"), Character("&"), Character("~"):
                let str = String(rawStatement[currentPos])
                items.append(TokenValue(token: Token.Operator, value: str))
                currentPos = currentPos.successor()
            case Character("?"):
                let str = String(rawStatement[currentPos])
                items.append(TokenValue(token: Token.Parameter, value: str))
                currentPos = currentPos.successor()
            case Character(";"):
                let str = String(rawStatement[currentPos])
                items.append(TokenValue(token: Token.Terminal, value: str))
                currentPos = currentPos.successor()
            case Character("0")..<Character("9"):
                let type: Token
                var nextPos = currentPos
                if rawStatement[currentPos] == Character("0") {
                    nextPos = nextPos.successor()
                    if rawStatement[nextPos] == Character("x") || rawStatement[nextPos] == Character("X") {
                        repeat {
                            nextPos = nextPos.successor()
                        } while hexadecimal.contains(String(rawStatement[nextPos]))
                        type = Token.Hexadecimal
                    } else if rawStatement[nextPos] == Character(".") {
                        repeat {
                            nextPos = nextPos.successor()
                        } while rawStatement[nextPos] >= Character("0") && rawStatement[nextPos] <= Character("9")
                        type = Token.Real
                    } else {
                        type = Token.Integer
                    }
                } else {
                    repeat {
                        nextPos = nextPos.successor()
                    } while rawStatement[nextPos] >= Character("0") && rawStatement[nextPos] <= Character("9")
                    
                    if rawStatement[nextPos] == Character(".") {
                        repeat {
                            nextPos = nextPos.successor()
                        } while rawStatement[nextPos] >= Character("0") && rawStatement[nextPos] <= Character("9")
                        type = Token.Real
                    } else {
                        type = Token.Integer
                    }
                }
                let str = rawStatement[currentPos..<nextPos]
                items.append(TokenValue(token: type, value: str))
                currentPos = nextPos
            case let (ch) where ch >= Character("x") || ch >= Character("X"):
                var nextPos = currentPos.successor()
                if rawStatement[nextPos] == Character("\'") {
                    nextPos = nextPos.successor()
                    while nextPos <= rawStatement.endIndex {
                        if rawStatement[nextPos] == Character("\'") {
                            if nextPos == rawStatement.endIndex || rawStatement[nextPos.successor()] != Character("\'") {
                                nextPos = nextPos.successor()
                                break
                            }
                            nextPos = nextPos.successor()
                        }
                        nextPos = nextPos.successor()
                    }
                    
                    let str = rawStatement[currentPos..<nextPos]
                    items.append(TokenValue(token: Token.Hexadecimal, value: str))
                    currentPos = nextPos
                } else {
                    repeat {
                        nextPos = nextPos.successor()
                    } while nextPos < rawStatement.endIndex && (rawStatement[nextPos] >= Character("a") && rawStatement[nextPos] <= Character("z")) || (rawStatement[nextPos] >= Character("A") && rawStatement[nextPos] <= Character("Z")) || rawStatement[nextPos] == Character("_") || rawStatement[nextPos] == Character(".") ||  (rawStatement[nextPos] >= Character("0") && rawStatement[nextPos] <= Character("9"))
                    
                    let str = rawStatement[currentPos..<nextPos]
                    let type = keywords.contains(str.uppercaseString) ? Token.Keyword : Token.Identifier
                    items.append(TokenValue(token: type, value: str))
                    currentPos = nextPos
                }
                
            case let (ch) where (ch >= Character("a") && ch <= Character("z")) || (ch >= Character("A") && ch <= Character("Z")) || ch == Character("_"):
                var nextPos = currentPos
                repeat {
                    nextPos = nextPos.successor()
                } while nextPos < rawStatement.endIndex && (rawStatement[nextPos] >= Character("a") && rawStatement[nextPos] <= Character("z")) || (rawStatement[nextPos] >= Character("A") && rawStatement[nextPos] <= Character("Z")) || rawStatement[nextPos] == Character("_") || rawStatement[nextPos] == Character(".") || (rawStatement[nextPos] >= Character("0") && rawStatement[nextPos] <= Character("9"))
                
                let str = rawStatement[currentPos..<nextPos]
                let type = keywords.contains(str.uppercaseString) ? Token.Keyword : Token.Identifier
                items.append(TokenValue(token: type, value: str))
                currentPos = nextPos
            default:
                let str = String(rawStatement[currentPos])
                items.append(TokenValue(token: Token.Other(str), value: str))
                currentPos = currentPos.successor()
            }
        }
    }
}