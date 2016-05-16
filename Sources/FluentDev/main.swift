import Fluent

import FluentSQLite
import FluentMongo

//Database.driver = PostgreSQLDriver(connectionInfo: "host='localhost' port='5432' dbname='demodb0' user='princeugwuh' password=''")

let sqlite: Database
let mongo: Database
let fake: Database

do {
    let sqliteDriver = try FluentSQLite.SQLiteDriver()
    sqlite = Database(driver: sqliteDriver)

    let mongoDriver = try FluentMongo.MongoDriver(name: "test")
    mongo = Database(driver: mongoDriver)

    fake = Database()
} catch {
    fatalError("Could not open database \(error)")
}

print("Hello, Fluent!")

do {
    let sqliteUser = try Query<User>(database: sqlite).all()
    let mongoUser = try Query<User>(database: mongo).all()
    let printUser = try Query<User>(database: fake).all()

    print([
        "sqlite": sqliteUser,
        "mongo": mongoUser,
        "print": printUser
    ])
} catch {
    print("Could not fetch \(error)")
}

/*

//: Model (Active Record)

do {
    let result = try User.first()
} catch ModelError.NotFound(let message) {
    print(message)
}
let _ = try? User.last()

let _ = try? User.take(50)
let _ = try? User.find(1)
let _ = try? User.find(1, 2, 4)
let _ = try? User.find("name", .Equals, "Jane Doe")
let _ = try? User.find("name", in: ["Tanner", "Jane"])

let u = User(name: "Vapor")
let _ = try? u.save()
u.id = "5" //simulate save
let _ = try? u.delete()

//: Query Builder - Different looks of using Query Builder Class

// Insert

let _ = try? Query<User>(database: sqlite).insert(u.serialize())

// Update

let _ = try? Query<User>(database: sqlite).update(u.serialize())

// Retrieve All Rows

let _ = try? Query<User>(database: sqlite).all()

// Retrieve A Single Row

let _ = try? Query<User>(database: sqlite).filter("name", "John").first()
let _ = try? Query<User>(database: sqlite).filter("name", .Equals, "Parker Collins").distinct().first() // with distinct

// Chucking

//-> TODO

// List / Pluck

let _ = try? Query<User>(database: sqlite).list("title")


// Aggregates

let _ = try? Query<User>(database: sqlite).count()
let _ = try? Query<User>(database: sqlite).count("name")
let _ = try? Query<User>(database: sqlite).maximum()
let _ = try? Query<User>(database: sqlite).minimum()
let _ = try? Query<User>(database: sqlite).average()

// Joins

let _ = try? Query<User>(database: sqlite).join(Address.self)?.all("\(Address.entity).*")

// Where

let _ = try? Query<User>(database: sqlite).filter("name", .Equals, "John").or { query in
    query.filter("phone", .NotEquals, "2234567890").and { query in
        query.filter("address", .Equals, "100 Apt Ln").filter("other", 1)
    }
    }.all()

// Order By

let _ = try? Query<User>(database: sqlite).filter("name", .Equals, "John").sort("name", .Ascending).all()

// Limit And Offset

let _ = try? Query<User>(database: sqlite).filter("name", .Equals, "John").limit().all()
let _ = try? Query<User>(database: sqlite).filter("name", .Equals, "Jane").limit(10).offset(5).all() */
