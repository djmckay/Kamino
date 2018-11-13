//
//  KaminoNilValidator.swift
//  App
//
//  Created by DJ McKay on 9/11/18.
//

import Foundation
import Core

extension KaminoValidator where T: OptionalType {
    /// Validates that the data is `nil`. Combine with the not-operator `!` to validate that the data is not `nil`.
    ///
    ///     try validations.add(\.email, .email && !.nil)
    ///
    public static var `nil`: KaminoValidator<T.WrappedType?> {
        return KaminoNilValidator(T.WrappedType.self).validator()
    }
}

/// Validates that the data is `nil`.
fileprivate struct KaminoNilValidator<T>: KaminoValidatorType {
    typealias ValidationData = T?
    
    /// See `Validator`.
    var validatorReadable: String {
        return "nil"
    }
    
    /// Creates a new `NilValidator`.
    init(_ type: T.Type) {}
    
    /// See `Validator`.
    func validate(_ data: T?) throws {
        if data != nil {
            throw KaminoBasicValidationError("is not nil")
        }
    }
}
