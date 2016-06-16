extension Model {
    public static func prepare(database: Database) throws {
        try database.create(entity) { builder in
            print("Preparing \(self.dynamicType)")

            let model = self.init()
            let mirror = Mirror(reflecting: model)

            for property in mirror.children {
                let name = property.label ?? ""
                let type = "\(property.value.dynamicType)"

                if name == database.driver.idKey {
                    builder.id()
                } else {
                    if type.contains("String") {
                        builder.string(name)
                    } else if type.contains("Int") {
                        builder.int(name)
                    }
                }
            }
        }
    }

    public static func revert(database: Database) throws {
        try database.delete(entity)
    }

    private init() {
        self.init(serialized: [:])
    }

    public func serialize() -> [String: Value?] {
        var serialized: [String: Value?] = [:]

        let mirror = Mirror(reflecting: self)
        for property in mirror.children {
            let name = property.label ?? ""
            let type = "\(property.value.dynamicType)"

            if let id = id {
                serialized["id"] = id.int ?? id.string
            }

            if type.contains("String") {
                if let string = property.value as? String {
                    serialized[name] = string
                }
            } else if type.contains("Int") {
                if let int = property.value as? Int {
                    serialized[name] = int
                }
            }
            
        }
        
        return serialized
    }
}
