//
//  CustomIdentifiedThing.swift
//  Fluent
//
//  Created by Matias Piipari on 10/02/2017.
//
//

import Foundation
import Fluent

struct CustomIdentifiedThing: Entity {
    
    var id:Node? = nil
    var exists: Bool = false
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
    }
    
    func makeNode(context: Context = EmptyNode) throws -> Node {
        return try Node(node: ["id": id])
    }
    
    static var idType: Schema.Field.KeyType { return .custom(type: "INTEGER") }
    
    static func prepare(_ database: Database) throws {
        try database.create(entity) { creator throws in
            creator.id(for: self)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(entity)
    }
}
