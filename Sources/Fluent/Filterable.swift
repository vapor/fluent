import Foundation

public protocol Filterable {
    var stringValue: String { get }
}

public extension Filterable {
    var stringValue: String {
        return String(self)
    }
}

extension Int:    Filterable {}
extension UInt:   Filterable {}

extension Bool:   Filterable {}

extension Int8:   Filterable {}
extension Int16:  Filterable {}
extension Int32:  Filterable {}
extension Int64:  Filterable {}

extension UInt8:  Filterable {}
extension UInt16: Filterable {}
extension UInt32: Filterable {}
extension UInt64: Filterable {}

extension Float:  Filterable {}
extension Double: Filterable {}

extension String: Filterable {}

extension NSDate: Filterable {
    public var stringValue: String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.stringFromDate(self)
    }
}