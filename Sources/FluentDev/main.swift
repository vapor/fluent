import Fluent

//Database.driver = PostgreSQLDriver(connectionInfo: "host='localhost' port='5432' dbname='demodb0' user='princeugwuh' password=''")

print("Hello, Fluent!")

//: Model (Active Record)

do {
let result = try User.first()
} catch ModelError.NotFound(let message) {
    print(message)
}
let _ = try? User.last()

let _ = try? User.take(count: 50)
let _ = try? User.find(id: 1)
let _ = try? User.find(ids: 1, 2, 4)
let _ = try? User.find(field: "name", .Equals, "Jane Doe")
let _ = try? User.find(field: "name", in: ["Tanner", "Jane"])

let u = User(name: "Vapor")
let _ = try? u.save()
u.id = "5" //simulate save
let _ = try? u.delete()

//: Query Builder - Different looks of using Query Builder Class

// Insert

let _ = try? Query<User>().insert(items: u.serialize())

// Update

let _ = try? Query<User>().update(items: u.serialize())

// Retrieve All Rows

let _ = try? Query<User>().all()

// Retrieve A Single Row

let _ = try? Query<User>().filter(field: "name", "John").first()
let _ = try? Query<User>().filter(field: "name", .Equals, "Parker Collins").distinct().first() // with distinct

// Chucking

//-> TODO

// List / Pluck

let _ = try? Query<User>().list(key: "title")


// Aggregates

let _ = try? Query<User>().count()
let _ = try? Query<User>().count(field: "name")
let _ = try? Query<User>().maximum()
let _ = try? Query<User>().minimum()
let _ = try? Query<User>().average()

// Joins

let _ = try? Query<User>().join(type: Address.self)?.all(fields: "\(Address.entity).*")

// Where

let _ = try? Query<User>().filter(field: "name", .Equals, "John").or { query in
    query.filter(field: "phone", .NotEquals, "2234567890").and { query in
		query.filter(field: "address", .Equals, "100 Apt Ln").filter(field: "other", 1)
   }
}.all()

// Order By

let _ = try? Query<User>().filter(field: "name", .Equals, "John").sort(field: "name", .Ascending).all()

// Limit And Offset

let _ = try? Query<User>().filter(field: "name", .Equals, "John").limit().all()
let _ = try? Query<User>().filter(field: "name", .Equals, "Jane").limit(count: 10).offset(count: 5).all()
