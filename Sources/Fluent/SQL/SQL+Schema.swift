extension SQL {
	public init(schema: Schema) {
        let action: TableAction
        let table: String

        switch schema {
        case .create(let entity, let fields):
            table = entity
            action = .create(columns: fields)
        case .modify(let entity, let fields, let delete):
            table = entity
            action = .alter(create: fields, delete: delete)
        case .delete(let entity):
            table = entity
            action = .drop
        }

        self = .table(action: action, table: table)
    }
}

extension Schema {
    public var sql: SQL {
        return SQL(schema: self)
    }
}
