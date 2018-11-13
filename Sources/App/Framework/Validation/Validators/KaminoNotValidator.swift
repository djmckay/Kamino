//
//  KaminoNotValidator.swift
//  App
//
//  Created by DJ McKay on 9/11/18.
//

import Foundation
/// Inverts a `Validation`.
///
///     try validations.add(\.email, .email && !.nil)
///
public prefix func !<T> (rhs: KaminoValidator<T>) -> KaminoValidator<T> {
    return KaminoNotValidator(rhs).validator()
}

// MARK: Private

/// Inverts a validator
fileprivate struct KaminoNotValidator<T>: KaminoValidatorType {
    /// See `ValidatorType`.
    typealias ValidationData = T
    
    /// See `ValidatorType`
    public var validatorReadable: String {
        return "not \(rhs.readable)"
    }
    
    /// The inverted `Validator`.
    let rhs: KaminoValidator<T>
    
    /// Creates a new `NotValidator`.
    init(_ rhs: KaminoValidator<T>) {
        self.rhs = rhs
    }
    
    /// See `ValidatorType`
    func validate(_ data: T) throws {
        var error: KaminoValidationError?
        do {
            try rhs.validate(data)
        } catch let e as KaminoValidationError {
            error = e
        }
        guard error != nil else {
            throw KaminoBasicValidationError("is \(rhs.readable)")
        }
    }
}
