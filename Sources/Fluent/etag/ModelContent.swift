import Vapor

/// Protocol meant for DTO type objects that are initializable by a `Model` object
public protocol ModelContent: Content {
    associatedtype ModelType: Model

    init(model: ModelType) throws
}
