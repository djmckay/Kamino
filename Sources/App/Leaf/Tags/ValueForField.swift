//
//  ValueForField.swift
//  App
//
//  Created by DJ McKay on 9/11/18.
//

import Foundation
import Leaf

public final class ValueForField: TagRenderer {
    
    /// Creates a new `ValueForField` tag renderer.
    public init() {}
    
    /// See `TagRenderer`.
    public func render(tag: TagContext) throws -> Future<TemplateData> {
        /// Require at least one parameter.
        switch tag.parameters.count {
        case 2: break
        default: throw tag.error(reason: "Invalid parameter count: \(tag.parameters.count). 2 required.")
        }
        let fieldset = tag.parameters[0].dictionary
        let fieldName = tag.parameters[1].string ?? ""
        let value = fieldset?[fieldName]?.string ?? ""
        
        /// Return formatted date
        return Future.map(on: tag) { .string(value) }
    }
    
}
