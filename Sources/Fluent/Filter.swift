//
//  Filter.swift
//  Fluent
//
//  Created by Tanner Nelson on 3/16/16.
//  Copyright © 2016 Qutheory. All rights reserved.
//

public enum Filter {
    case Compare(String, Comparison, Value)
    case Subset(String, Scope, [Value])
}

extension Filter: CustomStringConvertible {
    public var description: String {
        switch self {
        case .Compare(let field, let comparison, let value):
            return "\(field) \(comparison) \(value.string)"
        case .Subset(let field, let scope, let values):
            let valueDescriptions = values.map { value in
                return value.description
            }
            return "\(field) \(scope) \(valueDescriptions)"
        }
    }
}