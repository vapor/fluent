import Foundation

public protocol Value {
    var string: String { get }
}

public extension Value {
    var string: String {
        return String(self)
    }
    
    public var int: Int? {
        return Int(self.string)
    }
    
    public var float: Float? {
        return Float(self.string)
    }
    
    public var double: Double? {
        return Double(self.string)
    }
    
    public var bool: Bool? {
        let str = self.string.lowercased()
        
        if str == "true" || str == "1" {
            return true
        }
        
        if str == "false" || str == "0" {
            return false
        }
        
        return nil
    }
    
    public var date: NSDate? {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: self.string)
    }
}

extension Int:    Value {}
extension UInt:   Value {}

extension Bool:   Value {}

extension Int8:   Value {}
extension Int16:  Value {}
extension Int32:  Value {}
extension Int64:  Value {}

extension UInt8:  Value {}
extension UInt16: Value {}
extension UInt32: Value {}
extension UInt64: Value {}

extension Float:  Value {}
extension Double: Value {}

extension String: Value {}

extension NSNumber: Value {}
extension NSString: Value {}

extension NSDate: Value {
    public var string: String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }
}