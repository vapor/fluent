//
//  SubsetFilter..swift
//  Fluent
//
//  Created by Tanner Nelson on 3/16/16.
//  Copyright © 2016 Qutheory. All rights reserved.
//

public struct SubsetFilter: Filter {
    public var field: String
    var superSet: [Value]
}

extension SubsetFilter {
    public var description: String {
        let values = superSet.map { value in
            return value.description
        }
        return "\(field) in \(values)"
    }
}
