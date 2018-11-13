//
//  KaminoURLValidator.swift
//  App
//
//  Created by DJ McKay on 9/11/18.
//
import Foundation

extension KaminoValidator where T == String {
    /// Validates whether a `String` is a valid URL.
    ///
    ///     try validations.add(\.profilePictureURL, .url)
    ///
    ///     alternatively, if you want to allow an optional URL:
    ///
    ///     try validations.add(\.profilePictureURL, .url || .nil)
    ///
    /// This validator will allow either file URLs, or URLs
    /// containing at least a scheme and a host.
    ///
    public static var url: KaminoValidator<T> {
        return KaminoURLValidator().validator()
    }
}

// MARK: Private

/// Validates whether a string is a valid email address.
fileprivate struct KaminoURLValidator: KaminoValidatorType {
    typealias ValidationData = String
    
    /// See `ValidatorType`.
    public var validatorReadable: String {
        return "a valid URL"
    }
    
    /// Creates a new `URLValidator`.
    public init() {}
    
    /// See `Validator`.
    func validate(_ data: String) throws {
        guard let url = URL(string: data),
            url.isFileURL || (url.host != nil && url.scheme != nil) else {
                throw KaminoBasicValidationError("is not a valid URL")
        }
    }
}
