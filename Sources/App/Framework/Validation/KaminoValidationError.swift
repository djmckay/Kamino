//
//  KaminoValidationError.swift
//  App
//
//  Created by DJ McKay on 9/11/18.
//
import Vapor
import Debugging

public protocol KaminoValidationError: Debuggable {
    /// Key path to the invalid data.
    var path: [String] { get set }
}

extension KaminoValidationError {
    /// See `Debuggable`.
    public var identifier: String {
        return "validationFailed"
    }
}

struct KaminoBasicValidationError: KaminoValidationError {
    public var reason: String {
        let path: String
        if self.path.count > 0 {
            path = "'" + self.path.joined(separator: ".") + "'"
        } else {
            path = ""
        }
        return "\(path) \(message)"
    }
    
    /// The validation failure
    public var message: String
    public var id: String
    /// Key path the validation error happened at
    public var path: [String]
    
    /// Create a new JWT error
    public init(_ message: String, _ id: String) {
        self.message = message
        self.id = id
        self.path = [id]
    }
    
    public init(_ message: String) {
        self.message = message
        self.id = "none"
        self.path = []
    }
}
