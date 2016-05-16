/**
 *  Wrap - the easy to use Swift JSON encoder
 *
 *  For usage, see documentation of the classes/symbols listed in this file, as well
 *  as the guide available at: github.com/johnsundell/wrap
 *
 *  Copyright (c) 2015 John Sundell. Licensed under the MIT license, as follows:
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in all
 *  copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 *  SOFTWARE.
 */

import Foundation

/// Type alias defining what type of Dictionary that Wrap produces
public typealias WrappedDictionary = [String : AnyObject]
public typealias ResultDictionary = [String: Value]

func cast(from dict: [String: Value]) -> [String: AnyObject] {
    var result = [String: AnyObject]()
    
    for (key, value) in dict {
        result[key] = value as? AnyObject
    }
    
    return result
}

func cast(from dict: [String: AnyObject]) -> [String: Value] {
    var result = [String: Value]()
    
    for (key, value) in dict {
        result[key] = value as? Value
    }
    
    return result
}

/**
 *  Wrap any object or value, encoding it into a JSON compatible Dictionary
 *
 *  - Parameter object: The object to encode
 *  - Parameter dateFormatter: Optionally pass in a date formatter to use to encode any
 *    `NSDate` values found while encoding the object. If this is `nil`, any found date
 *    values will be encoded using the "yyyy-MM-dd HH:mm:ss" format.
 *
 *  All the type's stored properties (both public & private) will be recursively
 *  encoded with their property names as the key. For example, given the following
 *  Struct as input:
 *
 *  ```
 *  struct User {
 *      let name = "John"
 *      let age = 28
 *  }
 *  ```
 *
 *  This function will produce the following output:
 *
 *  ```
 *  [
 *      "name" : "John",
 *      "age" : 28
 *  ]
 *  ```
 *
 *  The object passed to this function must be an instance of a Class, or a value
 *  based on a Struct. Standard library values, such as Ints, Strings, etc are not
 *  valid input.
 *
 *  Throws a WrapError if the operation could not be completed.
 *
 *  For more customization options, make your type conform to `WrapCustomizable`,
 *  that lets you override encoding keys and/or the whole wrapping process.
 *
 *  See also `WrappableKey` (for dictionary keys) and `WrappableEnum` for Enum values.
 */
public func Wrap<T>(_ object: T, dateFormatter: NSDateFormatter? = nil) throws -> ResultDictionary {
    return cast(from: try Wrapper(dateFormatter: dateFormatter).wrap(object, enableCustomizedWrapping: true))
}

/**
 *  Alternative `Wrap()` overload that returns JSON-based `NSData`
 *
 *  See the documentation for the dictionary-based `Wrap()` function for more information
 */
public func Wrap<T>(_ object: T, writingOptions: NSJSONWritingOptions? = nil, dateFormatter: NSDateFormatter? = nil) throws -> NSData {
    return try Wrapper(dateFormatter: dateFormatter).wrap(object, writingOptions: writingOptions ?? [])
}

/**
 *  Alternative `Wrap()` overload that encodes an array of objects into an array of dictionaries
 *
 *  See the documentation for the dictionary-based `Wrap()` function for more information
 */
public func Wrap<T>(_ objects: [T], dateFormatter: NSDateFormatter? = nil) throws -> [ResultDictionary] {
    return try objects.map({ try Wrap($0) })
}

/**
 *  Alternative `Wrap()` overload that encodes an array of objects into JSON-based `NSData`
 *
 *  See the documentation for the dictionary-based `Wrap()` function for more information
 */
public func Wrap<T>(_ objects: [T], writingOptions: NSJSONWritingOptions? = nil, dateFormatter: NSDateFormatter? = nil) throws -> NSData {
    let dictionaries: [[String: AnyObject]] = try Wrap(objects).map { cast(from: $0) }
    //let dictionaries: [WrappedDictionary] = try Wrap(objects)
    return try NSJSONSerialization.data(withJSONObject: dictionaries, options: writingOptions ?? [])
}

/**
 *  Protocol providing the main customization point for Wrap
 *
 *  It's optional to implement all of the methods in this protocol, as Wrap
 *  supplies default implementations of them.
 */
public protocol WrapCustomizable {
    /**
     *  Override the wrapping process for this type
     *
     *  All top-level types should return a `WrappedDictionary` from this method.
     *
     *  You may use the default wrapping implementation by using a `Wrapper`, but
     *  never call `Wrap()` from an implementation of this method, since that might
     *  cause an infinite recursion.
     *
     *  Returning nil from this method will be treated as an error, and cause
     *  a `WrapError.WrappingFailedForObject()` error to be thrown.
     */
    func wrap() -> AnyObject?
    /**
     *  Override the key that will be used when encoding a certain property
     *
     *  Returning nil from this method will cause Wrap to skip the property
     */
    func keyForWrappingPropertyNamed(_ propertyName: String) -> String?
    /**
     *  Override the wrapping of any property of this type
     *
     *  The value passed to this method will be the original value that the type
     *  is currently storing for the property. You can choose to either use this,
     *  or just access the property in question directly.
     *
     *  Returning nil from this method will cause Wrap to use the default
     *  wrapping mechanism for the property, so you can choose which properties
     *  you want to customize the wrapping for.
     *
     *  If you encounter an error while attempting to wrap the property in question,
     *  you can choose to throw. This will cause a WrapError.WrappingFailedForObject
     *  to be thrown from the main `Wrap()` call that started the process.
     */
    func wrapPropertyNamed(_ propertyName: String, withValue value: Any) throws -> AnyObject?
}

/// Protocol implemented by types that may be used as keys in a wrapped Dictionary
public protocol WrappableKey {
    /// Convert this type into a key that can be used in a wrapped Dictionary
    func toWrappedKey() -> String
}

/**
 *  Protocol imlemented by Enums to enable them to be directly wrapped
 *
 *  If an Enum implementing this protocol conforms to `RawRepresentable` (it's based
 *  on a raw type), no further implementation is required. If you wish to customize
 *  how the Enum is wrapped, you can use the APIs in `WrapCustomizable`.
 */
public protocol WrappableEnum: WrapCustomizable {}

/**
 *  Class used to wrap an object or value. Use this in any custom `wrap()` implementations
 *  in case you only want to add on top of the default implementation.
 *
 *  You normally don't have to interact with this API. Use the `Wrap()` function instead
 *  to wrap an object from top-level code.
 */
public class Wrapper {
    private var dateFormatter: NSDateFormatter?
    
    /**
     *  Initialize an instance of this class, optionally with a date formatter
     *
     *  - Paramter dateFormatter: Any specific date formatter to use to encode any found `NSDate`
     *  values. If this is `nil`, any found date values will be encoded using the "yyyy-MM-dd
     *  HH:mm:ss" format.
     */
    public init(dateFormatter: NSDateFormatter? = nil) {
        self.dateFormatter = dateFormatter
    }
    
    /// Perform automatic wrapping of an object or value. For more information, see `Wrap()`.
    public func wrap(_ object: Any) throws -> WrappedDictionary {
        return try self.wrap(object, enableCustomizedWrapping: false)
    }
}

/// Error type used by Wrap
public enum WrapError: ErrorProtocol {
    /// Thrown when an invalid top level object (such as a String or Int) was passed to `Wrap()`
    case InvalidTopLevelObject(Any)
    /// Thrown when an object couldn't be wrapped. This is a last resort error.
    case WrappingFailedForObject(Any)
}

// MARK: - Default protocol implementations

/// Extension containing default implementations of `WrapCustomizable`. Override as you see fit.
public extension WrapCustomizable {
    func wrap() -> AnyObject? {
        return (try? Wrapper().wrap(self) as WrappedDictionary)
    }
    
    func keyForWrappingPropertyNamed(_ propertyName: String) -> String? {
        return propertyName
    }
    
    func wrapPropertyNamed(_ propertyName: String, withValue value: Any) throws -> AnyObject? {
        return try Wrapper().wrapValue(value, propertyName: propertyName)
    }
}

/// Extension providing a default wrapping implementation for `RawRepresentable` Enums
public extension WrappableEnum where Self: RawRepresentable {
    public func wrap() -> AnyObject? {
        return self.rawValue as? AnyObject
    }
}

/// Extension customizing how Arrays are wrapped
extension Array: WrapCustomizable {
    public func wrap() -> AnyObject? {
        return try? Wrapper().wrapCollection(self)
    }
}

/// Extension customizing how Dictionaries are wrapped
extension Dictionary: WrapCustomizable {
    public func wrap() -> AnyObject? {
        return try? Wrapper().wrapDictionary(self)
    }
}

/// Extension customizing how Sets are wrapped
extension Set: WrapCustomizable {
    public func wrap() -> AnyObject? {
        return try? Wrapper().wrapCollection(self)
    }
}

/// Extension customizing how NSStrings are wrapped
extension NSString: WrapCustomizable {
    public func wrap() -> AnyObject? {
        return self
    }
}

/// Extension customizing how NSURLs are wrapped
extension NSURL: WrapCustomizable {
    public func wrap() -> AnyObject? {
        return self.absoluteString
    }
}

/// Extension customizing how NSDictionaries are wrapped
extension NSDictionary: WrapCustomizable {
    public func wrap() -> AnyObject? {
        return try? Wrapper().wrapDictionary(self as [NSObject : AnyObject])
    }
}

/// Extension making Int a WrappableKey
extension Int: WrappableKey {
    public func toWrappedKey() -> String {
        return String(self)
    }
}

// MARK: - Private

private extension Wrapper {
    func wrap<T>(_ object: T, enableCustomizedWrapping: Bool) throws -> WrappedDictionary {
        if enableCustomizedWrapping {
            if let customizable = object as? WrapCustomizable {
                let wrapped = try self.performCustomWrappingForObject(customizable)
                
                guard let wrappedDictionary = wrapped as? WrappedDictionary else {
                    throw WrapError.InvalidTopLevelObject(object)
                }
                
                return wrappedDictionary
            }
        }
        
        var mirrors = [Mirror]()
        var currentMirror: Mirror? = Mirror(reflecting: object)
        
        while let mirror = currentMirror {
            mirrors.append(mirror)
            currentMirror = mirror.superclassMirror
        }
        
        return try self.performWrappingForObject(object, usingMirrors: mirrors.reversed())
    }
    
    func wrap<T>(_ object: T, writingOptions: NSJSONWritingOptions) throws -> NSData {
        let dictionary = try self.wrap(object, enableCustomizedWrapping: true)
        return try NSJSONSerialization.data(withJSONObject: dictionary, options: writingOptions)
    }
    
    func wrapValue<T>(_ value: T, propertyName: String? = nil) throws -> AnyObject {
        if let customizable = value as? WrapCustomizable {
            return try self.performCustomWrappingForObject(customizable)
        }
        
        let mirror = Mirror(reflecting: value)
        
        if mirror.children.isEmpty {
            if mirror.displayStyle == .some(.enum) {
                if let wrappableEnum = value as? WrappableEnum {
                    if let wrapped = wrappableEnum.wrap() {
                        return wrapped
                    }
                    
                    throw WrapError.WrappingFailedForObject(value)
                }
                
                return self.verifyWrappedValue("\(value)", propertyName: propertyName)
            } else if let date = value as? NSDate {
                return self.wrapDate(date)
            }
            
            return self.verifyWrappedValue(value, propertyName: propertyName)
        } else if value is NilLiteralConvertible && mirror.children.count == 1 {
            if let firstMirrorChild = mirror.children.first where firstMirrorChild.label == "Some" {
                return try self.wrapValue(firstMirrorChild.value, propertyName: propertyName)
            }
        }
        
        let wrapped = try self.wrap(value, enableCustomizedWrapping: false)
        
        return self.verifyWrappedValue(wrapped, propertyName: propertyName)
    }
    
    func wrapCollection<T: Collection>(_ collection: T) throws -> [AnyObject] {
        var wrappedArray = [AnyObject]()
        let wrapper = Wrapper()
        
        for element in collection {
            let wrapped = try wrapper.wrapValue(element)
            wrappedArray.append(wrapped)
        }
        
        return wrappedArray
    }
    
    func wrapDictionary<K: Hashable, V>(_ dictionary: [K : V]) throws -> WrappedDictionary {
        var wrappedDictionary = WrappedDictionary()
        let wrapper = Wrapper()
        
        for (key, value) in dictionary {
            let wrappedKey: String?
            
            if let stringKey = key as? String {
                wrappedKey = stringKey
            } else if let wrappableKey = key as? WrappableKey {
                wrappedKey = wrappableKey.toWrappedKey()
            } else if let stringConvertible = key as? CustomStringConvertible {
                wrappedKey = stringConvertible.description
            } else {
                wrappedKey = nil
            }
            
            if let wrappedKey = wrappedKey {
                wrappedDictionary[wrappedKey] = try wrapper.wrapValue(value, propertyName: wrappedKey)
            }
        }
        
        return wrappedDictionary
    }
    
    func wrapDate(_ date: NSDate) -> String {
        let dateFormatter: NSDateFormatter
        
        if let existingFormatter = self.dateFormatter {
            dateFormatter = existingFormatter
        } else {
            dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            self.dateFormatter = dateFormatter
        }
        
        return dateFormatter.string(from: date)
    }
    
    func performWrappingForObject<T>(_ object: T, usingMirrors mirrors: [Mirror]) throws -> WrappedDictionary {
        let customizable = object as? WrapCustomizable
        var wrappedDictionary = WrappedDictionary()
        
        for mirror in mirrors {
            for property in mirror.children {
                if "\(property.value)" == "nil" {
                    continue
                }
                
                guard let propertyName = property.label where propertyName != "Some" else {
                    continue
                }
                
                let wrappingKey: String?
                
                if let customizable = customizable {
                    wrappingKey = customizable.keyForWrappingPropertyNamed(propertyName)
                } else {
                    wrappingKey = propertyName
                }
                
                if let wrappingKey = wrappingKey {
                    if let wrappedProperty = try customizable?.wrapPropertyNamed(propertyName, withValue: property.value) {
                        wrappedDictionary[wrappingKey] = wrappedProperty
                    } else {
                        wrappedDictionary[wrappingKey] = try self.wrapValue(property.value, propertyName: propertyName)
                    }
                }
            }
        }
        
        return wrappedDictionary
    }
    
    func performCustomWrappingForObject(_ object: WrapCustomizable) throws -> AnyObject {
        guard let wrapped = object.wrap() else {
            throw WrapError.WrappingFailedForObject(object)
        }
        
        return wrapped
    }
    
    func verifyWrappedValue(_ value: Any, propertyName: String?) -> AnyObject {
        guard let object = value as? AnyObject else {
            return WrappedDictionary()
        }
        
        return object
    }
}