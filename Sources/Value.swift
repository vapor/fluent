/**
    A type of data that can be retrieved
    or stored in a database.
*/
public protocol Value: CustomStringConvertible {
    var structuredData: StructuredData { get }
}
