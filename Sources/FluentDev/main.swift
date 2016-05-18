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

    let mongoDriver = try FluentMongo.MongoDriver(
        database: "test",
        user: "test",
        password: "test",
        port: 27017
    )
    
    mongo = Database(driver: mongoDriver)

    //fake = Database()
} catch {
    fatalError("Could not open database \(error)")
}

print("Hello, Fluent!")

do {
    User.database = sqlite
    let sqliteUsers = try User.all()

    User.database = mongo
    let mongoUsers = try User.all()

    //User.database = fake
    //let _ = try User.all()

    print("SQLite Users")
    print(sqliteUsers)

    print("Mongo Users")
    print(mongoUsers)

    User.database = sqlite
    let sqliteUsersFilter = try User.query.filter("name", "Jill").all()

    User.database = mongo
    let mongoUsersFilter = try User.query.filter("name", "Jill").all()

    print("SQLite Users Filter")
    print(sqliteUsersFilter)

    print("Mongo Users Filter")
    print(mongoUsersFilter)

    //User.database = fake
    //let _ = try? User.find(1)

    User.database = sqlite
    let sqliteUser = try User.find(1)

    User.database = mongo
    let mongoUser = try User.find(1)

    print("SQLite Users Find")
    print(sqliteUser)

    print("Mongo Users Find")
    print(mongoUser)

    var newMongoUser = User(name: "Bill")
    var newSqliteUser = User(name: "Bills")

    User.database = sqlite
    try newSqliteUser.save()

    User.database = mongo
    try newMongoUser.save()

    print("SQLite User Save")
    print(newSqliteUser)

    print("Mongo User Save")
    print(newMongoUser)

    User.database = sqlite
    try newSqliteUser.delete()

    User.database = mongo
    try newMongoUser.delete()

    print("SQLite User Delete")
    print(newSqliteUser)

    print("Mongo User Delete")
    print(newMongoUser)


    User.database = sqlite
    let sqliteUsersSubset = try User.query.filter("name", .in, ["Jill", "Tanner"]).all()

    User.database = mongo
    let mongoUsersSubset = try User.query.filter("name", .in, ["Jill", "Tanner"]).all()

    print("SQLite Users Subset")
    print(sqliteUsersSubset)

    print("Mongo Users Subset")
    print(mongoUsersSubset)

    User.database = sqlite
    let sqliteUsersInverseSubset = try User.query.filter("name", .notIn, ["Bills", "Tanner"]).all()

    User.database = mongo
    let mongoUsersInverseSubset = try User.query.filter("name", .notIn, ["Bill", "Tanner"]).all()

    print("SQLite Users Inverse Subset")
    print(sqliteUsersInverseSubset)

    print("Mongo Users Inverse Subset")
    print(mongoUsersInverseSubset)
} catch {
    print("Could not fetch. Error: \(error)")
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
