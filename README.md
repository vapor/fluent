![Fluent](https://cloud.githubusercontent.com/assets/1342803/12735105/1bdfb1d0-c913-11e5-9b45-f7a6f7cba720.png)

# Fluent

Simple ActiveRecord implementation for working with your database in Swift.

- [x] Easy setup
- [x] Beautiful syntax
- [x] Generically typed

## Getting Started

Clone the [Example](https://github.com/qutheory/fluent-example) project to start making your application. If you are also looking for a web server, check out [Vapor](https://github.com/qutheory/vapor). It was built to work well with Fluent.

You must have Swift 2.2 or later installed. You can learn more about Swift 2.2 at [Swift.org](http://swift.org)

### Work in Progress

This is a work in progress, so don't rely on this for anything important. And pull requests are welcome!

## Example

Using Fluent is simple and expressive.

```swift
if let user = User.find(5) {
	print("Found \(user.name)")

	user.name = "New Name"
	user.save()
}
```

Underlying Fluent is a powerful Query builder.

```swift
let user = Query<User>().filter("id", notIn: [1, 2, 3]).filter("age", .GreaterThan, 21).first
```

## Setup

Start by importing Fluent into your application.

```swift
import Fluent
```

`Package.swift`

```swift
import PackageDescription

let package = Package(
    name: "FluentApp",
    dependencies: [
        .Package(url: "https://github.com/qutheory/fluent.git", majorVersion: 0)
    ]
)
```

## Drivers

Fluent currently supports `SQLite`. Support for `MySQL`, and `MongoDB` are in the works.

### Print Driver

By default, the `PrintDriver` is enabled. This driver will simply print out the commands you make to Fluent. This is only useful for development of Fluent. 

### SQLite

Start by ensuring `SQLite3` is installed on your machine. If you are on a Mac, it will already be installed. For Linux, simply run `sudo apt-get install libsqlite3-dev`. 

Once `SQLite3` is installed, add the Fluent `SQLiteDriver` to your project.

`Package.swift`

```swift
.Package(url: "https://github.com/tannernelson/fluent-sqlite-driver.git", majorVersion: 0)
```

Then `import` the driver and set it as your default database driver.

```swift
import SQLiteDriver

Database.driver = SQLiteDriver()
```

You are now ready to use SQLite. The database file will be stored in `Database/main.sqlite`.

## Models

Make your application models conform to the `Model` protocol to allow them to work with Fluent.

```swift
public protocol Model {
	///The entities database identifier. `nil` when not saved yet.
	var id: String? { get }

	///The database table in which entities are stored.
	static var table: String { get }

	/**
		This method will be called when the entity is saved. 
		The keys of the dictionary are the column names
		in the database.
	*/
	func serialize() -> [String: String]

	init(serialized: [String: String])
}
```

When your application models conform to the `Model` protocol, they gain access to the following helper functions.

```swift
extension Model {
	public func save()
	public func delete()
	public static func find(id: Int) -> Self?
}
```

## Querying

Create an instance of the query builder by passing one of your application models that conforms to the `Model` protocol.

```swift
let query = Query<User>()
```

### Filters

You can filter by equivalence relations, as well is `in/not in` relations.


#### Compare

```swift
query.filter("age", .GreaterThan, 21)
```

```swift
public enum Comparison {
	case Equals, NotEquals, GreaterThanOrEquals, LessThanOrEquals, GreaterThan, LessThan
}
```

#### Subset

```swift
query.filter("id", in: [1, 2, 3])
```

```swift
public enum Comparison {
	case In, NotIn
}
```

### Results

Call `.results` for all of the results from the query, or `.first` for only the first result.

### Delete

Call `.delete` to delete all rows affected by the query.

### Save

Call `.save(model: T)`, passing in an instance of the class used to instantiate the `Query` to save it. This performs the same function as calling `.save()` on the model itself.

## Deploying

Fluent has been successfully tested on Ubuntu 14.04 LTS (DigitalOcean) and Ubuntu 15.10 (VirtualBox). 

To deploy to DigitalOcean, simply 

- Install Swift 2.2
	- `wget` the .tar.gz from Apple
	- Set the `export PATH` in your `~/.bashrc`
	- (you may need to install `binutils` as well if you see `ar not found`)
- Clone your fork of the `fluent-example` repository to the server
- `cd` into the repository
	- Run `swift build`
	- Run `.build/debug/MyApp`

My website `http://tanner.xyz` is currently running using Vapor and Fluent.
