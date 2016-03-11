public class SchemaTable: SchemaType {
	let builder: SchemaBuilder

	public init(name: String, builder: SchemaBuilder) {
		self.builder = builder
		super.init(name: name)
	}

	public func create(ifNotExists ifNotExists: Bool, handler: SchemaTableBuilder.Handler) {
		let builder = SchemaTableBuilder(table: self, type: .Create)
		handler(builder)
		self.builder.driver.create(table: self.name, ifNotExists: ifNotExists, builder: builder)
	}

	public func alter(handler: SchemaTableBuilder.Handler) {
		let builder = SchemaTableBuilder(table: self, type: .Alter)
		handler(builder)
		self.builder.driver.alter(table: self.name, builder: builder)
	}

}
