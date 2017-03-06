//
//  StringIdentifiedThing.swift
//  Fluent
//
//  Created by Matias Piipari on 10/02/2017.
//
//

import Foundation

import Fluent

final class StringIdentifiedThing: Entity {
    static var idKey = "#id"
    let storage = Storage()
    
    init(node: Node) throws {
        id = try node.get(idKey)
    }
    
    func makeNode(in context: Context?) throws -> Node {
        return try Node(node: [idKey: id])
    }
    
    static var idType: IdentifierType { return .custom("STRING(10)") }
    
    static func prepare(_ database: Database) throws {
        try database.create(self) { creator throws in
            creator.id(for: self)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}
