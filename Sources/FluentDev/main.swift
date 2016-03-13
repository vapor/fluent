import Fluent

print("Hello, Fluent!")

//: Model (Active Record)

User.first()
User.last()

User.take(50)
User.find(1)
User.find(1, 2, 4)
User.findBy("name", .Equals, "Jane Doe")

let u = User(deserialize: [:])
u.save()
u.delete()

//: Query Builder - Different looks of using Query Builder Class

// Insert

Query<User>().insert(u.serialize()).run()

// Update

Query<User>().update(u.serialize()).run()

// Retrieve All Rows

Query<User>().all()

// Retrieve A Single Row

Query<User>().with("name", .Equals, "John").first()
Query<User>().with("name", .Equals, "John").distinct().first() // with distinct

// Chucking

//-> TODO

// List / Pluck

Query<User>().list("title")


// Aggregates

Query<User>().count()
Query<User>().count("name")
Query<User>().max()
Query<User>().min()
Query<User>().avg()

// Joins

Query<User>().join(Address.self, .Left)?.all("\(Address.entity).*")

// Where

Query<User>().with("date", .Between, "10/10/2000", "10/10/2005").andWith("name", .Equals, "John").orWith("phone", .NotEquals, "2234567890").groupBy("name").all()

// Group By

Query<User>().with("name", .Equals, "John").groupBy("name").all()

// Order By

Query<User>().with("name", .Equals, "John").orderBy("name", .Ascending).all()

// Limit And Offset

Query<User>().with("name", .Equals, "John").limit().all()

Query<User>().with("name", .Equals, "Jane").limit(10).offset(5).all()
