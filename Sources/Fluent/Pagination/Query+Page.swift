extension QueryRepresentable where E: Paginatable {
    public func paginate(
        page: Int,
        count: Int = E.pageSize,
        _ sorts: [Sort] = E.pageSorts
    ) throws -> Page<E> {
        guard page > 0 else {
            throw PaginationError.invalidPageNumber(page)
        }
        // require page 1 or greater
        let page = page > 0 ? page : 1

        // create the query and get a total count
        let query = try makeQuery()
        let total = try query.count()

        // limit the query to the desired page
        try query.limit(count, offset: (page - 1) * count)
        
        // add the sorts w/o replacing
        _ = try sorts.map(query.sort)

        // fetch the data
        let data = try query.all()

        return try Page(
            number: page,
            data: data,
            size: count,
            total: total
        )
    }
}
