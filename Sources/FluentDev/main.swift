import Fluent

//
////Database.driver = PostgreSQLDriver(connectionInfo: "host='localhost' port='5432' dbname='demodb0' user='princeugwuh' password=''")
//
//print("Hello, Fluent!")
//
////: Model (Active Record)
//
//do {
//    let result = try User.first()
//} catch ModelError.NotFound(let message) {
//    print(message)
//}
//let _ = try? User.last()
//
//let _ = try? User.take(50)
//let _ = try? User.find(1)
//let _ = try? User.find(1, 2, 4)
//let _ = try? User.find(where: "name" == "Jane Doe")
//let _ = try? User.find(where: "name" =~ ["Tanner", "Jane"])
//
//let u = User(name: "Vapor")
//let _ = try? u.save()
//u.id = "5" //simulate save
//let _ = try? u.delete()
//
////: Query Builder - Different looks of using Query Builder Class
//
//// Insert
//
//let _ = try? Query<User>().insert(u.serialize())
//
//// Update
//
//let _ = try? Query<User>().update(u.serialize())
//
//// Retrieve All Rows
//
//let _ = try? Query<User>().all()
//
//// Retrieve A Single Row
//
//let _ = try? Query<User>().filter("name", "John").first()
//let _ = try? Query<User>().filter("name", .Equals, "Parker Collins").distinct().first() // with distinct
//
//// Chucking
//
////-> TODO
//
//// List / Pluck
//
//let _ = try? Query<User>().list("title")
//
//
//// Aggregates
//
//let _ = try? Query<User>().count()
//let _ = try? Query<User>().count("name")
//let _ = try? Query<User>().maximum()
//let _ = try? Query<User>().minimum()
//let _ = try? Query<User>().average()
//
//// Joins
//
//let _ = try? Query<User>().join(Address.self)?.all("\(Address.entity).*")
//
//// Where
//
//let _ = try? Query<User>().filter("name", .Equals, "John").or { query in
//    query.filter("phone", .NotEquals, "2234567890").and { query in
//        query.filter("address", .Equals, "100 Apt Ln").filter("other", 1)
//    }
//    }.all()
//
//// Order By
//
//let _ = try? Query<User>().filter("name", .Equals, "John").sort("name", .Ascending).all()
//
//// Limit And Offset
//
//let _ = try? Query<User>().filter("name", .Equals, "John").limit().all()
//let _ = try? Query<User>().filter("name", .Equals, "Jane").limit(10).offset(5).all()
