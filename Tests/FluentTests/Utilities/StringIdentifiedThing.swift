//
//  StringIdentifiedThing.swift
//  Fluent
//
//  Created by Matias Piipari on 10/02/2017.
//
//

import Foundation

import Fluent

struct StringIdentifiedThing: Entity {
    static var idKey = "#id"
    var id: Node? = nil
    let storage = Storage()
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
    }
    
    func makeNode(context: Context = EmptyNode) throws -> Node {
        return try Node(node: ["id": id])
    }
    
    static var idType: IdentifierType { return .custom("STRING(10)") }
    
    static func prepare(_ database: Database) throws {
        try database.create(entity) { creator throws in
            creator.id(for: self)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(entity)
    }
}
