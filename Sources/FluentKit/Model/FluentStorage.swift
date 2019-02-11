public protocol FluentStorage {
    var output: FluentOutput? { get }
    var input: [String: FluentQuery.Value] { get set }
    var eagerLoads: [String: EagerLoad] { get set }
    var exists: Bool { get set }
    var path: [String] { get }
}

struct ModelStorage: FluentStorage {
    static let empty: ModelStorage = .init(
        output: nil,
        eagerLoads: [:],
        exists: false
    )
    
    var output: FluentOutput?
    var input: [String: FluentQuery.Value]
    var eagerLoads: [String: EagerLoad]
    var exists: Bool
    var path: [String] {
        return []
    }

    init(output: FluentOutput?, eagerLoads: [String: EagerLoad], exists: Bool) {
        self.output = output
        self.eagerLoads = eagerLoads
        self.input = [:]
        self.exists = exists
    }
}

struct NestedOutput: FluentOutput {
    let name: String
    let base: FluentOutput
    init(name: String, _ base: FluentOutput) {
        self.name = name
        self.base = base
    }
    
    var description: String {
        return self.base.description
    }
    
    func decode<T>(field: String, as type: T.Type) throws -> T where T: Decodable {
        let base = try self.base.decode(
            field: self.name,
            as: DecoderUnwrapper.self
        )
        let decoder = try base.decoder.container(keyedBy: StringCodingKey.self)
        return try decoder.decode(T.self, forKey: .init(field))
    }
}

struct NestedStorage: FluentStorage {
    let name: String
    let base: FluentEntity
    let dataType: FluentSchema.DataType?
    let constraints: [FluentSchema.FieldConstraint]
    
    var path: [String] {
        return self.base.storage.path + [self.name]
    }
    
    var output: FluentOutput? {
        return self.base.storage.output.flatMap { output in
            return NestedOutput(name: self.name, output)
        }
    }
    
    var input: [String: FluentQuery.Value] {
        get {
            switch self.base.storage.input[self.name] {
            case .none: return [:]
            case .some(let some):
                switch some {
                case .dictionary(let dict): return dict
                default: return [:]
                }
            }
        }
        set { self.base.storage.input[self.name] = .dictionary(newValue) }
    }
    
    var eagerLoads: [String: EagerLoad] {
        get { return self.base.storage.eagerLoads }
        set { self.base.storage.eagerLoads = newValue }
    }
    
    var exists: Bool {
        get { return self.base.storage.exists }
        set { self.base.storage.exists = newValue }
    }
}

extension FluentEntity {
    public func nested<Nested>(
        _ name: String,
        _ dataType: FluentSchema.DataType? = nil,
        _ constraints: FluentSchema.FieldConstraint...
    ) -> Nested
        where Nested: FluentEntity
    {
        let storage = NestedStorage(
            name: name,
            base: self,
            dataType: dataType,
            constraints: constraints
        )
        return .init(storage: storage)
    }
}

public protocol FluentNestedModel: FluentEntity { }

extension FluentNestedModel {
    public var property: FluentProperty {
        return NestedProperty(entity: self)
    }
}

struct NestedProperty<Nested>: FluentProperty
    where Nested: FluentNestedModel
{
    let entity: Nested
    
    init(entity: Nested) {
        self.entity = entity
    }
    
    public var name: String {
        guard let storage = self.entity.storage as? NestedStorage else {
            fatalError()
        }
        return storage.name
    }
    
    var dataType: FluentSchema.DataType? {
        guard let storage = self.entity.storage as? NestedStorage else {
            fatalError()
        }
        return storage.dataType
    }
    
    var constraints: [FluentSchema.FieldConstraint] {
        guard let storage = self.entity.storage as? NestedStorage else {
            fatalError()
        }
        return storage.constraints
    }
    
    public var type: Any.Type {
        return Nested.self
    }
    
    public func encode(to container: inout KeyedEncodingContainer<StringCodingKey>) throws {
        try container.encode(self.entity, forKey: StringCodingKey(self.name))
    }
    
    public func decode(from container: KeyedDecodingContainer<StringCodingKey>) throws {
        let model = try container.decode(Nested.self, forKey: StringCodingKey(self.name))
        self.entity.storage = model.storage
    }
}
