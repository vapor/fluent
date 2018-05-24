extension DataManipulationStatement: QueryAction {
    public var fluentIsCreate: Bool {
        switch verb {
        case "INSERT": return true
        default: return false
        }
    }

    public static var fluentCreate: DataManipulationStatement {
        return .insert()
    }

    public static var fluentRead: DataManipulationStatement {
        return .select()
    }

    public static var fluentUpdate: DataManipulationStatement {
        return .update()
    }

    public static var fluentDelete: DataManipulationStatement {
        return .delete()
    }
}
