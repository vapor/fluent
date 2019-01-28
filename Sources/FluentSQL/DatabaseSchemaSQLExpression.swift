internal struct DatabaseSchemaConverter {
    public let schema: FluentSchema
    
    public init(_ schema: FluentSchema) {
        self.schema = schema
    }
    
    internal func convert() -> SQLExpression {
        switch self.schema.action {
        case .create:
            return self.create()
        case .delete:
            return self.delete()
        default:
            #warning("TODO:")
            fatalError("\(self) not yet supported")
        }
    }
    
    // MARK: Private
    
    private func delete() -> SQLExpression {
        var delete = SQLDropTable(table: self.name(self.schema.entity))
        return delete
    }
    
    private func create() -> SQLExpression {
        var create = SQLCreateTable(name: self.name(self.schema.entity))
        create.columns = self.schema.createFields.map(self.fieldDefinition)
        return create
    }
    
    private func name(_ string: String) -> SQLExpression {
        return SQLIdentifier(string)
    }
    
    private func fieldDefinition(_ fieldDefinition: FluentSchema.FieldDefinition) -> SQLExpression {
        switch fieldDefinition {
        case .custom(let any):
            return any as! SQLExpression
        case .definition(let name, let dataType, let constraints):
            return SQLColumnDefinition(
                column: self.fieldName(name),
                dataType: self.dataType(dataType),
                constraints: constraints.map(self.fieldConstraint)
            )
        }
    }
    
    private func fieldName(_ fieldName: FluentSchema.FieldName) -> SQLExpression {
        switch fieldName {
        case .custom(let any):
            return any as! SQLExpression
        case .string(let string):
            return SQLIdentifier(string)
        }
    }
    
    private func dataType(_ dataType: FluentSchema.DataType) -> SQLExpression {
        switch dataType {
        case .bool: return SQLDataType.int
        case .data: return SQLDataType.blob
        case .date: return SQLDataType.real
        case .datetime: return SQLDataType.real
        case .custom(let any): return any as! SQLExpression
        case .int64: return SQLDataType.bigint
        case .string: return SQLDataType.text
        default:
            #warning("TODO:")
            fatalError("\(dataType) not yet supported")
        }
    }
    
    private func fieldConstraint(_ fieldConstraint: FluentSchema.FieldConstraint) -> SQLExpression {
        switch fieldConstraint {
        case .custom(let any):
            return any as! SQLExpression
        case .primaryKey:
            return SQLColumnConstraint.primaryKey
        }
    }
}
