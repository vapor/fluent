//import Node
//
//extension MemoryDriver {
//    final class Group {
//        var increment: Int
//        var data: [Node]
//
//        func create(_ node: Node, idKey: String) -> Int {
//            increment += 1
//            var node = node
//
//            if var n = node.nodeObject {
//                n[idKey] = Node.number(.int(increment))
//                node = Node.object(n)
//            }
//
//            data.append(node)
//            return increment
//        }
//
//        func delete(_ filters: [Filter]) {
//            data = data.fails(filters)
//        }
//
//        func fetch(_ filters: [Filter], _ sorts: [Sort], _ limit: Limit? = nil) -> [Node] {
//            var dataToReturn = data.passes(filters).sort(sorts)
//            
//            if let limit = limit {
//                if dataToReturn.count > 0 {
//                    var count = limit.count + limit.offset - 1
//                    
//                    if limit.offset > dataToReturn.count {
//                        return []
//                    }
//                    
//                    if count >= dataToReturn.count {
//                        count = dataToReturn.count - 1
//                    }
//                    
//                    dataToReturn = Array(dataToReturn[limit.offset...count])
//                }
//            }
//            
//            return dataToReturn
//        }
//
//        func modify(_ update: Node, filters: [Filter]) -> [Node] {
//            var modified: [Node] = []
//
//            for (key, node) in data.enumerated() {
//                if node.passes(filters) {
//                    data[key] = update
//                    modified += update
//                }
//            }
//
//            return modified
//        }
//
//        init(data: [Node] = [], increment: Int = 0) {
//            self.data = data
//            self.increment = increment
//        }
//    }
//}
