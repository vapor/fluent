extension SQL {
	public init(schema: Schema) {
        let action: TableAction
        let table: String

        switch schema {
        case .create(let entity, let fields):
            table = entity
            action = .create(columns: fields.columns)
        case .modify(let entity, let create, let delete):
            table = entity
            action = .alter(create: create.columns, delete: delete)
        case .delete(let entity):
            table = entity
            action = .drop
        }

        self = .table(action: action, table: table)
    }
}

extension Collection where Iterator.Element == Schema.Field {
    var columns: [SQL.Column] {
        var columns: [SQL.Column] = []

        for field in self {
            let column: SQL.Column

            switch field {
            case .id:
                column = .primaryKey
            case .int(let name):
                column = .integer(name)
            case .string(let name, let length):
                column = .string(name, length: length)
            case .double(let name, let digits, let decimal):
                column = .double(name, digits: digits, decimal: decimal)
            }

            columns.append(column)
        }

        return columns
    }

}

extension Schema {
    public var sql: SQL {
        return SQL(schema: self)
    }
}
