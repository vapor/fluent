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
            if let _ = try Migration.query().filter("name", preparation.name).first() {
                // already prepared, set entity db
                if let model = preparation as? Entity.Type {
                    model.database = self
                }

                return true
            }
        } catch {
            // could not fetch migrations
            // try to create `.fluent` table
            try Migration.prepare(self)
        }

        return false
    }

    public func prepare(_ preparation: Preparation.Type) throws {
        Migration.database = self

        if try hasPrepared(preparation) {
            throw PreparationError.alreadyPrepared
        }

        try preparation.prepare(self)

        if let model = preparation as? Entity.Type {
            // preparation successful, set entity db
            model.database = self
        }


        // record that this preparation has run
        let migration = Migration(name: preparation.name)
        try migration.save()
    }
}

extension Preparation {
    fileprivate static var name: String {
        let type = "\(type(of: self))"
        return type.components(separatedBy: ".Type").first ?? type
    }
}
