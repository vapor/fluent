//
//  ComparisonFilter.swift
//  Fluent
//
//  Created by Tanner Nelson on 3/16/16.
//  Copyright © 2016 Qutheory. All rights reserved.
//

public struct ComparisonFilter: Filter {
    public enum Comparison: CustomStringConvertible {
        case Equals, GreaterThan, LessThan
        
        public var description: String {
            switch self {
            case .Equals:
                return "="
            case .GreaterThan:
                return ">"
            case .LessThan:
                return "<"
            }
        }
    }
    var field: String
    var comparison: Comparison
    var value: Value
    
    init(_ field: String, _ comparison: Comparison, _ value: Value) {
        self.field = field
        self.comparison = comparison
        self.value = value
    }
 
}

extension ComparisonFilter {
    public var description: String {
        return "\(field) \(comparison) \(value.description)"
    }
}