extension Tester {
    public func testCustomKeys() throws {
        Bloguser.database = database
        try Bloguser.prepare(database)
        Blogpost.database = database
        try Blogpost.prepare(database)
        BloguserFollowersPivot.database = database
        try BloguserFollowersPivot.prepare(database)
        /*
            ALTERNATIVE TO CREATING A CUSTOM PIVOT
         
            Pivot<Bloguser, Bloguser>.name = "userFollowers"
            Pivot<Bloguser, Bloguser>.leftIdKey = "followingId"
            Pivot<Bloguser, Bloguser>.rightIdKey = "followerId"
            try Pivot<Bloguser, Bloguser>.prepare(database)
         */
        
        defer {
            /// try! Pivot<Bloguser, Bloguser>.revert(database)
            try! BloguserFollowersPivot.revert(database)
            try! Blogpost.revert(database)
            try! Bloguser.revert(database)
        }
        
        let gert = Bloguser(name: "Gertrude")
        try gert.save()
        
        let alb = Bloguser(name: "Albert")
        try alb.save()
        
        // first post
        do {
            let firstPost = try Blogpost(text: "Hello, world", createdBy: alb)
            try firstPost.save()
            
            guard try alb.createdPosts.all().count == 1 else {
                throw Error.failed("Created post was not found on user.")
            }
            
            guard try alb.updatedPosts.all().count == 0 else {
                throw Error.failed("User should have no updated posts yet.")
            }
            
            firstPost.updatedById = try alb.assertExists()
            try firstPost.save()
            
            guard try alb.updatedPosts.all().count == 1 else {
                throw Error.failed("Updated post was not found on user.")
            }
        }
    
        // followers
        do {
            guard try alb.followers.all().count == 0 else {
                throw Error.failed("User should not have any followers yet.")
            }
            
            try alb.followers.add(gert)
            
            guard try alb.followers.all().count == 1 else {
                throw Error.failed("User should have one follower.")
            }
            
            guard try gert.following.all().count == 1 else {
                throw Error.failed("User should be following one user.")
            }
        }
        
        
    }
}

// MARK: Types

// PIVOT

final class BloguserFollowersPivot: PivotProtocol, Entity, Preparation {
    typealias Left = Bloguser
    typealias Right = Bloguser
    
    static let leftIdKey = "followerId"
    static let rightIdKey = "followingId"

    var followerId: Identifier
    var followingId: Identifier
    var storage = Storage()
    
    init(row: Row) throws {
        followerId = try row.get(type(of: self).leftIdKey)
        followingId = try row.get(type(of: self).rightIdKey)
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(type(of: self).leftIdKey, followerId)
        try row.set(type(of: self).rightIdKey, followingId)
        return row
    }
    
    static func prepare(_ database: Database) throws {
        try database.create(self) { pivot in
            pivot.id()
            pivot.foreignId(for: Left.self, foreignIdKey: leftIdKey)
            pivot.foreignId(for: Right.self, foreignIdKey: rightIdKey)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}


// USER

final class Bloguser: Entity, Preparation {
    var name: String
    let storage = Storage()
    
    var createdPosts: Children<Bloguser, Blogpost> {
        return children(foreignIdKey: "createdBy")
    }
    
    var updatedPosts: Children<Bloguser, Blogpost> {
        return children(foreignIdKey: "updatedby")
    }
    
    var followers: Siblings<Bloguser, Bloguser, BloguserFollowersPivot> {
        return siblings(
            localIdKey: BloguserFollowersPivot.leftIdKey,
            foreignIdKey: BloguserFollowersPivot.rightIdKey
        )
    }
    
    var following: Siblings<Bloguser, Bloguser, BloguserFollowersPivot> {
        return siblings(
            localIdKey: BloguserFollowersPivot.rightIdKey,
            foreignIdKey: BloguserFollowersPivot.leftIdKey
        )
    }
    
    init(name: String) {
        self.name = name
    }
    
    init(row: Row) throws {
        name = try row.get("name")
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("name", name)
        return row
    }
    
    static func prepare(_ database: Database) throws {
        try database.create(self) { users in
            users.id()
            users.string("name")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// POST

final class Blogpost: Entity, Preparation {
    var text: String
    var createdById: Identifier
    var updatedById: Identifier?
    let storage = Storage()
    
    var createdBy: Parent<Blogpost, Bloguser> {
        return parent(id: createdById)
    }
    
    var updatedBy: Parent<Blogpost, Bloguser>? {
        guard let id = updatedById else {
            return nil
        }
        return parent(id: id)
    }
    
    init(text: String, createdBy: Bloguser) throws {
        self.text = text
        self.createdById = try createdBy.assertExists()
    }
    
    init(row: Row) throws {
        text = try row.get("text")
        createdById = try row.get("createdBy")
        updatedById = try row.get("updatedBy")
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("text", text)
        try row.set("createdBy", createdById)
        try row.set("updatedBy", updatedById)
        return row
    }
    
    static func prepare(_ database: Database) throws {
        try database.create(self) { posts in
            posts.id()
            posts.string("text")
            posts.parent(Bloguser.self, foreignIdKey: "createdBy")
            posts.parent(Bloguser.self, optional: true, foreignIdKey: "updatedBy")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}
