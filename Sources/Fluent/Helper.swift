//
//  Helper.swift
//  Fluent
//
//  Created by Tanner Nelson on 3/16/16.
//  Copyright © 2016 Qutheory. All rights reserved.
//

public class Helper<T: Model> {
    
    var query: Query<T>
    
    public init(query: Query<T>) {
        self.query = query
    }
}