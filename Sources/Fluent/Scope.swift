//
//  SubsetFilter..swift
//  Fluent
//
//  Created by Tanner Nelson on 3/16/16.
//  Copyright © 2016 Qutheory. All rights reserved.
//

extension Filter {
    public enum Scope {
        case In, NotIn
    }
}

extension Filter.Scope: CustomStringConvertible {
    public var description: String {
        return self == .In ? "in" : "not in"
    }
}
