public class SchemaBuilder {
	public let driver: Driver

	public init(driver: Driver) {
		self.driver = driver
	}

	public func create(table table: String, ifNotExists: Bool = false, handler: SchemaTableBuilder.Handler) {
		SchemaTable(name: table, builder: self).create(ifNotExists: ifNotExists, handler: handler)
	}

	public func alter(table table: String, ifNotExists: Bool = false, handler: SchemaTableBuilder.Handler) {
		SchemaTable(name: table, builder: self).alter(handler)
	}

	public func rename(table table: String, to: String) {
		self.driver.rename(table: table, to: to)
	}

}
