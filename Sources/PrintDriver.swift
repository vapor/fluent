import Foundation

class PrintDriver: Driver {
    var statementClass: StatementGenerator.Type {
        return SQL.self
    }
    
    func execute(statement: StatementGenerator) -> [[String : String]]? {
        print("FULL QUERY: \(statement.query)")
        print("PARAMETERIZED QUERY: \(statement.parameterizedQuery)")
        print("QUERY VALUES: \(statement.queryValues)")
        print()
        return nil
    }
}