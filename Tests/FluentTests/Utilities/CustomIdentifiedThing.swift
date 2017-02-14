//
//  CustomIdentifiedThing.swift
//  Fluent
//
//  Created by Matias Piipari on 10/02/2017.
//
//

import Foundation
import Fluent

final class CustomIdentifiedThing: Entity {
    let storage = Storage()
    static let idKey = "#id"
    
    init(node: Node, in context: Context) throws {
        id = try node.extract(idKey)
    }
    
    func makeNode(context: Context = EmptyNode) throws -> Node {
        return try Node(node: [idKey: id])
    }
    
    static var idType: IdentifierType { return .custom("INTEGER") }
    
    static func prepare(_ database: Database) throws {
        try database.create(entity) { creator throws in
            creator.id(for: self)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(entity)
    }
}
