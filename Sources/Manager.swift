class Manager {

	static var driver: Driver = MemoryDriver()

	class func query(query: Query) -> Any? {
		return self.driver.query(query)
	}

}