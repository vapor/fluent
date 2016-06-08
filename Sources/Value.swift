/**
    A type of data that can be retrieved
    or stored in a database.
*/
public protocol Value: CustomStringConvertible, Polymorphic {
    var structuredData: StructuredData { get }
}
