//
//  KaminoAndValidator.swift
//  App
//
//  Created by DJ McKay on 9/11/18.
//
import Vapor
/// Combines two `Validator`s using AND logic, succeeding if both `Validator`s succeed without error.
///
///     try validations.add(\.name, .range(5...) && .alphanumeric)
///
public func &&<T> (lhs: KaminoValidator<T>, rhs: KaminoValidator<T>) -> KaminoValidator<T> {
    return AndValidator(lhs, rhs).validator()
}

/// Combines two validators, if either both succeed the validation will succeed.
fileprivate struct AndValidator<T>: KaminoValidatorType {
    /// See `ValidatorType`.
    public var validatorReadable: String {
        return "\(lhs.readable) and is \(rhs.readable)"
    }
    
    /// left validator
    let lhs: KaminoValidator<T>
    
    /// right validator
    let rhs: KaminoValidator<T>
    
    /// create a new and validator
    init(_ lhs: KaminoValidator<T>, _ rhs: KaminoValidator<T>) {
        self.lhs = lhs
        self.rhs = rhs
    }
    
    /// See `ValidatorType`.
    func validate(_ data: T) throws {
        var left: KaminoValidationError?
        do {
            try lhs.validate(data)
        } catch let l as KaminoValidationError {
            left = l
        }
        
        var right: KaminoValidationError?
        do {
            try rhs.validate(data)
        } catch let r as KaminoValidationError {
            right = r
        }
        
        if left != nil || right != nil {
            throw KaminoAndValidatorError(left, right)
        }
    }
}

/// Error thrown if and validation fails
fileprivate struct KaminoAndValidatorError: KaminoValidationError {
    /// error thrown by left validator
    let left: KaminoValidationError?
    
    /// error thrown by right validator
    let right: KaminoValidationError?
    
    /// See ValidationError.reason
    var reason: String {
        if let left = left, let right = right {
            var mutableLeft = left, mutableRight = right
            mutableLeft.path = path + left.path
            mutableRight.path = path + right.path
            return "\(mutableLeft.reason) and \(mutableRight.reason)"
        } else if let left = left {
            var mutableLeft = left
            mutableLeft.path = path + left.path
            return mutableLeft.reason
        } else if let right = right {
            var mutableRight = right
            mutableRight.path = path + right.path
            return mutableRight.reason
        } else {
            return ""
        }
    }
    
    /// See ValidationError.keyPath
    var path: [String]
    
    /// Creates a new or validator error
    init(_ left: KaminoValidationError?, _ right: KaminoValidationError?) {
        self.left = left
        self.right = right
        self.path = []
    }
}
