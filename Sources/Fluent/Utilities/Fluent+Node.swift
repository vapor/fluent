@_exported import Node

public enum ExtractionError: Error {
    case notDictionary
    case invalidType
}

extension Node {
    public func extract(_ key: String) throws -> [UInt8] {
        guard case .object(let dict) = self else {
            throw ExtractionError.notDictionary
        }

        guard let node = dict[key] else {
            throw ExtractionError.invalidType
        }


        switch node {
        case .bytes(let data):
            return data
        case .string(_):
            return []
        default:
            throw ExtractionError.invalidType
        }
    }

    public func extract(_ key: String) throws -> Bool {
        guard case .object(let dict) = self else {
            throw ExtractionError.notDictionary
        }

        guard let bool = dict[key]?.bool else {
            print("\(key) not Bool")
            throw ExtractionError.invalidType
        }

        return bool
    }

    public func extract(_ key: String) throws -> Double {
        guard case .object(let dict) = self else {
            throw ExtractionError.notDictionary
        }

        guard let double = dict[key]?.double else {
            print("\(key) not Double")
            throw ExtractionError.invalidType
        }

        return double
    }

    public func extract(_ key: String) throws -> Int {
        guard case .object(let dict) = self else {
            throw ExtractionError.notDictionary
        }

        guard let int = dict[key]?.int else {
            print("\(key) not Int")
            throw ExtractionError.invalidType
        }

        return int
    }

    public func extract(_ key: String) throws -> String {
        guard case .object(let dict) = self else {
            throw ExtractionError.notDictionary
        }

        guard let string = dict[key]?.string else {
            print("\(key) not String. \(dict)")
            throw ExtractionError.invalidType
        }

        return string
    }

    public func extract(_ key: String) throws -> Node {
        guard case .object(let dict) = self else {
            throw ExtractionError.notDictionary
        }

        guard let node = dict[key] else {
            print("\(key) not Node")
            throw ExtractionError.invalidType
        }
        
        return node
    }
}
