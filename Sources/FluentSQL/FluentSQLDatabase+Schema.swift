extension FluentSQLDatabase {
    internal func convert(_ schema: FluentSchema) -> SQLExpression {
        switch schema.action {
        case .create:
            return self.create(schema)
        case .delete:
            return self.delete(schema)
        default:
            #warning("TODO:")
            fatalError("\(self) not yet supported")
        }
    }
    
    // MARK: Private
    
    private func delete(_ schema: FluentSchema) -> SQLExpression {
        var delete = SQLDropTable(table: self.name(schema.entity))
        return delete
    }
    
    private func create(_ schema: FluentSchema) -> SQLExpression {
        var create = SQLCreateTable(name: self.name(schema.entity))
        create.columns = schema.createFields.map(self.fieldDefinition)
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
        case .date: return SQLRaw("DATE")
        case .datetime: return SQLRaw("TIMESTAMP")
        case .custom(let any): return any as! SQLExpression
        case .int64: return SQLDataType.bigint
        case .string: return SQLDataType.text
        case .json:
            #warning("TODO: get better support for this")
            return SQLRaw("JSON")
        case .uuid:
            #warning("TODO: get better support for this")
            return SQLRaw("UUID")
        default:
            #warning("TODO:")
            fatalError("\(dataType) not yet supported")
        }
    }
    
    private func fieldConstraint(_ fieldConstraint: FluentSchema.FieldConstraint) -> SQLExpression {
        switch fieldConstraint {
        case .required:
            return SQLColumnConstraint.notNull
        case .custom(let any):
            return any as! SQLExpression
        case .identifier:
            return SQLColumnConstraint.primaryKey
        }
    }
}
