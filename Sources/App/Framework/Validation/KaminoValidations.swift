//
//  KaminoValidations.swift
//  App
//
//  Created by DJ McKay on 9/11/18.
//
import Vapor

public struct KaminoValidations<M>: CustomStringConvertible where M: KaminoValidatable {
    /// Internal storage.
    fileprivate var storage: [KaminoValidator<M>]
    
    /// See `CustomStringConvertible`.
    public var description: String {
        return storage.map { $0.description }.joined(separator: "\n")
    }
    
    /// Create an empty `Validations` struct. You can also use an empty array `[]`.
    public init(_ model: M.Type) {
        self.storage = []
    }
    
    /// Adds a new `Validation` at the supplied key path and readable path.
    ///
    ///     try validations.add(\.name, at: ["name"], .count(5...) && .alphanumeric)
    ///
    /// - parameters:
    ///     - keyPath: `KeyPath` to validatable property.
    ///     - path: Readable path. Will be displayed when showing errors.
    ///     - validation: `Validation` to run on this property.
    public mutating func add<T>(_ keyPath: KeyPath<M, T>, at path: [String], _ validator: KaminoValidator<T>) {
        add(keyPath, at: path, "is " + validator.readable, { value in
            try validator.validate(value, path.first)
        })
    }
    
    /// Adds a custom `Validation` at the supplied key path and readable path.
    ///
    ///     try validations.add(\.name, at: ["name"], "is vapor") { name in
    ///         guard name == "vapor" else { throw }
    ///     }
    ///
    /// - parameters:
    ///     - keyPath: `KeyPath` to validatable property.
    ///     - path: Readable path. Will be displayed when showing errors.
    ///     - readable: Readable string describing this validation.
    ///     - custom: Closure accepting the `KeyPath`'s value. Throw a `ValidationError` here if the data is invalid.
    public mutating func add<T>(_ keyPath: KeyPath<M, T>, at path: [String], _ readable: String, _ custom: @escaping (T) throws -> Void) {
        add("\(path.joined(separator: ".")): \(readable)") { model in
            do {
                try custom(model[keyPath: keyPath])
            } catch var error as KaminoValidationError {
                error.path += path
                let kaminoError = KaminoBasicValidationError(error.reason, path.first ?? "")
                throw kaminoError
                //throw error
            }
        }
    }
    
    /// Adds a custom `Validation` to the `Validations`.
    ///
    ///     try validations.add("name: is vapor") { model in
    ///         guard model.name == "vapor" else { throw }
    ///     }
    ///
    /// - parameters:
    ///     - readable: Readable string describing this validation.
    ///     - custom: Closure accepting an instance of the model. Throw a `ValidationError` here if the model is invalid.
    public mutating func add(_ readable: String, _ custom: @escaping (M) throws -> Void) {
        let modelValidator: KaminoValidator<M> = .init(readable) { model in
            try custom(model)
        }
        storage.append(modelValidator)
    }
    
    /// Runs the `Validation`s on an instance of `M`.
    public func run(on model: M) throws {
        var errors: [KaminoValidationError] = []
        for validation in storage {
            /// run the validation, catching validation errors
            do {
                try validation.validate(model)
            } catch let error as KaminoValidationError {
                errors.append(error)
            }
        }
        
        if !errors.isEmpty {
            throw KaminoValidateErrors(errors)
        }
    }
    
    
}

extension KaminoValidations where M: Reflectable {
    /// Adds a new `Validation` at the supplied key path. Readable path will be reflected.
    ///
    ///     try validations.add(\.name, .count(5...) && .alphanumeric)
    ///
    /// - parameters:
    ///     - keyPath: `KeyPath` to validatable property.
    ///     - validation: `Validation` to run on this property.
    public mutating func add<T>(_ keyPath: KeyPath<M, T>, _ validator: KaminoValidator<T>) throws {
        try add(keyPath, at: M.reflectProperty(forKey: keyPath)?.path ?? [], validator)
    }
    
    
    /// Adds a new custom `Validation` at the supplied key path. Readable path will be reflected.
    ///
    ///     try validations.add(\.name, "is vapor") { name in
    ///         guard name == "vapor" else { throw }
    ///     }
    ///
    /// - parameters:
    ///     - keyPath: `KeyPath` to validatable property.
    ///     - readable: Readable string describing this validation.
    ///     - custom: Closure accepting the `KeyPath`'s value. Throw a `ValidationError` here if the data is invalid.
    public mutating func add<T>(_ keyPath: KeyPath<M, T>, _ readable: String, _ custom: @escaping (T) throws -> Void) throws {
        try add(keyPath, at: M.reflectProperty(forKey: keyPath)?.path ?? [], readable, custom)
    }
}

// MARK: Private

/// A collection of errors thrown by validatable models validations
public struct KaminoValidateErrors: KaminoValidationError {
    /// the errors thrown
    var errors: [KaminoValidationError]
    
    /// See ValidationError.keyPath
    public var path: [String]
    
    /// See ValidationError.reason
    public var reason: String {
        return errors.map { error in
            var mutableError = error
            mutableError.path = path + error.path
            return mutableError.reason
            }.joined(separator: ", ")
    }
    
    /// creates a new validatable error
    init(_ errors: [KaminoValidationError]) {
        self.errors = errors
        self.path = []
    }
}

public struct KaminoDBValidations<M>: CustomStringConvertible where M: KaminoValidatable {
    /// Internal storage.
    fileprivate var storage: [KaminoDBValidator<M>]
    
    /// See `CustomStringConvertible`.
    public var description: String {
        return storage.map { $0.description }.joined(separator: "\n")
    }
    
    /// Create an empty `Validations` struct. You can also use an empty array `[]`.
    public init(_ model: M.Type) {
        self.storage = []
    }
    
    /// Adds a new `Validation` at the supplied key path and readable path.
    ///
    ///     try validations.add(\.name, at: ["name"], .count(5...) && .alphanumeric)
    ///
    /// - parameters:
    ///     - keyPath: `KeyPath` to validatable property.
    ///     - path: Readable path. Will be displayed when showing errors.
    ///     - validation: `Validation` to run on this property.
//    public mutating func add<T>(_ keyPath: KeyPath<M, T>, at path: [String], _ validator: KaminoDBValidator<T>) -> Future<Void> {
//        return try add(keyPath, at: path, "is " + validator.readable, { value in
//            return try validator.validate(value, path.first)
//        })
//    }
    
    /// Adds a custom `Validation` at the supplied key path and readable path.
    ///
    ///     try validations.add(\.name, at: ["name"], "is vapor") { name in
    ///         guard name == "vapor" else { throw }
    ///     }
    ///
    /// - parameters:
    ///     - keyPath: `KeyPath` to validatable property.
    ///     - path: Readable path. Will be displayed when showing errors.
    ///     - readable: Readable string describing this validation.
    ///     - custom: Closure accepting the `KeyPath`'s value. Throw a `ValidationError` here if the data is invalid.
    public mutating func add<T>(_ keyPath: KeyPath<M, T>, at path: [String], _ readable: String, _ custom: @escaping (T) throws -> Future<Void>) {
        add("\(path.joined(separator: ".")): \(readable)") { model in
            do {
                return try custom(model[keyPath: keyPath])
            } catch var error as KaminoValidationError {
                error.path += path
                let kaminoError = KaminoBasicValidationError(error.reason, path.first ?? "")
                throw kaminoError
                //throw error
            }
        }
    }
    
    /// Adds a custom `Validation` to the `Validations`.
    ///
    ///     try validations.add("name: is vapor") { model in
    ///         guard model.name == "vapor" else { throw }
    ///     }
    ///
    /// - parameters:
    ///     - readable: Readable string describing this validation.
    ///     - custom: Closure accepting an instance of the model. Throw a `ValidationError` here if the model is invalid.
    public mutating func add(_ readable: String, _ custom: @escaping (M) throws -> Future<Void>) {
        let modelValidator: KaminoDBValidator<M> = .init(readable) { model in
            return try custom(model)
        }
        storage.append(modelValidator)
    }
    
    /// Runs the `Validation`s on an instance of `M`.
    public func run(on model: M) throws {
        var errors: [KaminoValidationError] = []
        for validation in storage {
            /// run the validation, catching validation errors
            do {
                try _ = validation.validate(model)
            } catch let error as KaminoValidationError {
                errors.append(error)
            }
        }
        
        if !errors.isEmpty {
            throw KaminoValidateErrors(errors)
        }
    }
    
    
}

