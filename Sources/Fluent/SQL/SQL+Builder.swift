extension SQL {
	init(builder: Schema.Builder) {
        var columns: [Column] = []

        for field in builder.fields {
            let column: Column

            switch field {
            case .int(let name):
                column = .integer(name)
            case .string(let name, let length):
                column = .string(name, length)
            }

            columns.append(column)
        }

        self = .table(action: .create, table: builder.entity, columns: columns)
    }
}
