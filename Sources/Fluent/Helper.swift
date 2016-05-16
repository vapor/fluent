//
//  Helper.swift
//  Fluent
//
//  Created by Tanner Nelson on 3/16/16.
//  Copyright © 2016 Qutheory. All rights reserved.
//

public class Helper<T: Entity> {
    
    var query: QueryParameters<T>
    
    public init(query: QueryParameters<T>) {
        self.query = query
    }
}