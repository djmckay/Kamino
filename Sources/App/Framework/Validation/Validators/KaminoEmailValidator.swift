//
//  KaminoEmailValidator.swift
//  App
//
//  Created by DJ McKay on 9/11/18.
//

extension KaminoValidator where T == String {
    /// Validates whether a `String` is a valid email address.
    ///
    ///     try validations.add(\.email, .email)
    ///
    public static var email: KaminoValidator<T> {
        return KaminoEmailValidator().validator()
    }
}

// MARK: Private

/// Validates whether a string is a valid email address.
fileprivate struct KaminoEmailValidator: KaminoValidatorType {
    /// See `ValidatorType`.
    public var validatorReadable: String {
        return "a valid email address"
    }
    
    /// Creates a new `EmailValidator`.
    public init() {}
    
    /// See `Validator`.
    public func validate(_ s: String) throws {
        guard
            let range = s.range(of: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}", options: [.regularExpression, .caseInsensitive]),
            range.lowerBound == s.startIndex && range.upperBound == s.endIndex
            else {
                throw KaminoBasicValidationError("is not a valid email address")
        }
    }
}
