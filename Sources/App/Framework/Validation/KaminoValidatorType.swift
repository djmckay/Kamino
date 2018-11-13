//
//  KaminoValidatorType.swift
//  App
//
//  Created by DJ McKay on 9/11/18.
//

/// Capable of validating validation data or throwing a validation error.
/// Use this protocol to organize code for creating `Validator`s.
///
///     let validator: Validator<T> = MyValidator().validator()
///
/// See `Validator` for more information.
public protocol KaminoValidatorType {
    /// Data type to validate.
    associatedtype ValidationData
    
    /// Readable name explaining what this `Validator` does. Suitable for placing after `is` _and_ `is not`.
    ///
    ///     is alphanumeric
    ///     is not alphanumeric
    ///
    var validatorReadable: String { get }
    /// Validates the supplied `ValidationData`, throwing an error if it is not valid.
    ///
    /// - parameters:
    ///     - data: `ValidationData` to validate.
    /// - throws: `ValidationError` if the data is not valid, or another error if something fails.
    func validate(_ data: ValidationData) throws
}

extension KaminoValidatorType {
    /// Create a `Validator` for this `ValidatorType`.
    public func validator() -> KaminoValidator<ValidationData> {
        return KaminoValidator(validatorReadable, validate)
    }
}
