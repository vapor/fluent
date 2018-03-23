import Foundation
import Fluent


struct Snowman: Model {
    
    typealias Database = FakeDatabase
    
    typealias ID = UUID
    
    let id: ID
    let name: String
    let hasCarrot: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case hasCarrot = "carrot"
    }
}
