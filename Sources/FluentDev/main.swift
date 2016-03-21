import Fluent

//Database.driver = PostgreSQLDriver(connectionInfo: "host='localhost' port='5432' dbname='demodb0' user='princeugwuh' password=''")

print("Hello, Fluent!")

//: Model (Active Record)

User.first()
User.last()

User.take(50)
User.find(1)
User.find(1, 2, 4)
User.find("name", .Equals, "Jane Doe")
User.find("name", in: ["Tanner", "Jane"])

let u = User(name: "Vapor")
u.save()
u.id = "5" //simulate save
u.delete()

//: Query Builder - Different looks of using Query Builder Class

// Insert

Query<User>().insert(u.serialize())

// Update

Query<User>().update(u.serialize())

// Retrieve All Rows

Query<User>().all()

// Retrieve A Single Row

Query<User>().filter("name", "John").first()
Query<User>().filter("name", .Equals, "Parker Collins").distinct().first() // with distinct

// Chucking

//-> TODO

// List / Pluck

Query<User>().list("title")


// Aggregates

Query<User>().count()
Query<User>().count("name")
Query<User>().maximum()
Query<User>().minimum()
Query<User>().average()

// Joins

Query<User>().join(Address.self)?.all("\(Address.entity).*")

// Where

Query<User>().filter("name", .Equals, "John").or { query in
    query.filter("phone", .NotEquals, "2234567890").and { query in
        query.filter("address", .Equals, "100 Apt Ln").filter("other", 1)
   }
}.all()

// Order By

Query<User>().filter("name", .Equals, "John").sort("name", .Ascending).all()

// Limit And Offset

Query<User>().filter("name", .Equals, "John").limit().all()

Query<User>().filter("name", .Equals, "Jane").limit(10).offset(5).all()
