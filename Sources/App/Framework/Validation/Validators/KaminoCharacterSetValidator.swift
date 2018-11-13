//
//  KaminoCharacterSetValidator.swift
//  App
//
//  Created by DJ McKay on 9/11/18.
//

import Foundation
extension KaminoValidator {
    /// Validates that all characters in a `String` are ASCII (bytes 0..<128).
    ///
    ///     try validations.add(\.name, .ascii)
    ///
    public static var ascii: KaminoValidator<String> {
        return .characterSet(.ascii)
    }
    
    /// Validates that all characters in a `String` are alphanumeric (a-z,A-Z,0-9).
    ///
    ///     try validations.add(\.name, .alphanumeric)
    ///
    public static var alphanumeric: KaminoValidator<String> {
        return .characterSet(.alphanumerics)
    }
    
    /// Validates that all characters in a `String` are in the supplied `CharacterSet`.
    ///
    ///     try validations.add(\.name, .characterSet(.alphanumerics + .whitespaces))
    ///
    public static func characterSet(_ characterSet: CharacterSet) -> KaminoValidator<String> {
        return KaminoCharacterSetValidator(characterSet).validator()
    }
}

/// Unions two character sets.
///
///     .characterSet(.alphanumerics + .whitespaces)
///
public func +(lhs: CharacterSet, rhs: CharacterSet) -> CharacterSet {
    return lhs.union(rhs)
}


// MARK: Private

/// Validates that a `String` contains characters in a given `CharacterSet`
fileprivate struct KaminoCharacterSetValidator: KaminoValidatorType {
    
    /// `CharacterSet` to validate against.
    let characterSet: CharacterSet
    
    /// See `Validator`
    public var validatorReadable: String {
        if characterSet.traits.count > 0 {
            let string = characterSet.traits.joined(separator: ", ")
            return "in character set (\(string))"
        } else {
            return "in character set"
        }
    }
    
    /// Creates a new `CharacterSetValidator`.
    init(_ characterSet: CharacterSet) {
        self.characterSet = characterSet
    }
    
    /// See `Validator`
    public func validate(_ s: String) throws {
        if let range = s.rangeOfCharacter(from: characterSet.inverted) {
            var reason = "contains an invalid character: '\(s[range])'"
            if characterSet.traits.count > 0 {
                let string = characterSet.traits.joined(separator: ", ")
                reason += " (allowed: \(string))"
            }
            throw KaminoBasicValidationError(reason)
        }
    }
}

extension CharacterSet {
    /// ASCII (byte 0..<128) character set.
    fileprivate static var ascii: CharacterSet {
        var ascii: CharacterSet = .init()
        for i in 0..<128 {
            ascii.insert(Unicode.Scalar(i)!)
        }
        return ascii
    }
}


extension CharacterSet {
    /// Returns an array of strings describing the contents of this `CharacterSet`.
    fileprivate var traits: [String] {
        var desc: [String] = []
        if isSuperset(of: .newlines) {
            desc.append("newlines")
        }
        if isSuperset(of: .whitespaces) {
            desc.append("whitespace")
        }
        if isSuperset(of: .capitalizedLetters) {
            desc.append("A-Z")
        }
        if isSuperset(of: .lowercaseLetters) {
            desc.append("a-z")
        }
        if isSuperset(of: .decimalDigits) {
            desc.append("0-9")
        }
        return desc
    }
}
