//
//  Validatable.swift
//  App
//
//  Created by DJ McKay on 9/11/18.
//
import Vapor

/// Capable of being validated. Conformance adds a throwing `validate()` method.
///
///     struct User: Validatable, Reflectable {
///         var name: String
///         var age: Int
///
///         static func validations() throws -> Validations<User> {
///             var validations = Validations(User.self)
///             // validate name is at least 5 characters and alphanumeric
///             try validations.add(\.name, .count(5...) && .alphanumeric)
///             return validations
///         }
///     }
///
public protocol KaminoValidatable {
    /// The validations that will run when `validate()` is called on an instance of this class.
    ///
    ///     struct User: Validatable, Reflectable {
    ///         var name: String
    ///         var age: Int
    ///
    ///         static func validations() throws -> Validations<User> {
    ///             var validations = Validations(User.self)
    ///             // validate name is at least 5 characters and alphanumeric
    ///             try validations.add(\.name, .count(5...) && .alphanumeric)
    ///             return validations
    ///         }
    ///     }
    ///
    static func validations() throws -> KaminoValidations<Self>
}

extension KaminoValidatable {
    /// Validates the model, throwing an error if any of the validations fail.
    ///
    ///     let user = User(name: "Vapor", age: 3)
    ///     try user.validate()
    ///
    /// - note: Non-validation errors may also be thrown should the validators encounter unexpected errors.
    public func validate() throws {
        try Self.validations().run(on: self)
    }
    
}

public protocol KaminoDatabaseValidatable: KaminoValidatable {
    static func validations(conn: DatabaseConnectable) throws -> KaminoDBValidations<Self>

}

extension KaminoDatabaseValidatable {
    /// Validates the model, throwing an error if any of the validations fail.
    ///
    ///     let user = User(name: "Vapor", age: 3)
    ///     try user.validate()
    ///
    /// - note: Non-validation errors may also be thrown should the validators encounter unexpected errors.
    
    public func validate(conn: DatabaseConnectable) throws -> Future<Void> {
        try Self.validations().run(on: self)
        
        return try conn.future(Self.validations(conn: conn).run(on: self))
    }
}
