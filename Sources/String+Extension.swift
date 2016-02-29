import Foundation

public extension String {
    public func trim() -> String {
        return self.stringByTrimmingCharactersInSet(.whitespaceAndNewlineCharacterSet())
    }
    
    public func isMatch(string: String, options: NSRegularExpressionOptions = .CaseInsensitive) -> Bool {
        let regex: NSRegularExpression
        let length = characters.count
        
        do {
            regex = try NSRegularExpression(pattern: string, options: options)
        } catch {
            return false
        }
        
        let numberOfMatches = regex.numberOfMatchesInString(self, options: NSMatchingOptions(rawValue: 0), range: NSMakeRange(0, length))
        return numberOfMatches > 0
    }
    
    public func matches(string: String, options: NSRegularExpressionOptions = .CaseInsensitive) -> [NSTextCheckingResult]? {
        let length = characters.count
        let regex: NSRegularExpression
        
        do {
            regex = try NSRegularExpression(pattern: string, options: options)
        } catch {
            return nil
        }
        
        let matches = regex.matchesInString(self, options: NSMatchingOptions(rawValue: 0), range: NSMakeRange(0, length))
        return matches
    }
    
    public func stringByEscapingSQLStatement() -> String {
        var str = self
        str = str.stringByReplacingOccurrencesOfString("\'", withString: "\\'")
        str = str.stringByReplacingOccurrencesOfString("'", withString: "''")
        str = str.stringByReplacingOccurrencesOfString("\"", withString: "\\\"")
        str = str.stringByReplacingOccurrencesOfString("/", withString: "\\/")
        str = str.stringByReplacingOccurrencesOfString("\n", withString: "\\n")
        str = str.stringByReplacingOccurrencesOfString("%", withString: "%%")
        str = str.stringByReplacingOccurrencesOfString("\r", withString: "\\r")
        str = str.stringByReplacingOccurrencesOfString("\t", withString: "\\t")
        return str
    }
    
    public func stringByUnescapintSQLStatement() -> String {
        var str = self
        str = str.stringByReplacingOccurrencesOfString("\\'", withString: "\'")
        str = str.stringByReplacingOccurrencesOfString("''", withString: "'")
        str = str.stringByReplacingOccurrencesOfString("\\\"", withString: "\"")
        str = str.stringByReplacingOccurrencesOfString("\\/", withString: "/")
        str = str.stringByReplacingOccurrencesOfString("\\n", withString: "\n")
        str = str.stringByReplacingOccurrencesOfString("%%", withString: "%")
        str = str.stringByReplacingOccurrencesOfString("\\r", withString: "\r")
        str = str.stringByReplacingOccurrencesOfString("\\t", withString: "\t")
        return str
    }
}