import Foundation
import Fluent


struct Snowman: Model {
    
    static var idKey: WritableKeyPath<Snowman, UUID?> = \Snowman.id as! WritableKeyPath<Snowman, UUID?>
    
    typealias Database = FakeDatabase
    
    typealias ID = UUID
    
    let id: ID?
    let name: String
    let hasCarrot: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case hasCarrot = "carrot"
    }
    
}
