extension Database {
    public func prepare(_ preparations: [Preparation.Type]) throws {
        for preparation in preparations {
            try prepare(preparation)
        }
    }

    public func hasPrepared(_ preparation: Preparation.Type) throws -> Bool {
        Migration.database = self

        do {
            // check to see if this preparation has already run
            if let _ = try Migration.filter("name", preparation.name).first() {
                return true
            }
        } catch {
            // could not fetch migrations
            // try to create `.fluent` table
            try Migration.prepare(database: self)
        }

        return false
    }

    public func prepare(_ preparation: Preparation.Type) throws {
        Migration.database = self

        // set the current database on involved Models
        if let model = preparation as? Model.Type {
            model.database = self
        }


        if try hasPrepared(preparation) {
            throw PreparationError.alreadyPrepared
        }

        try preparation.prepare(database: self)

        // record that this preparation has run
        var migration = Migration(name: preparation.name)
        try migration.save()
    }
}

extension Preparation {
    public static var name: String {
        let type = "\(self.dynamicType)"
        return type.components(separatedBy: ".Type").first ?? type
    }
}
