//
//  ConfigValue.swift
//  App
//
//  Created by DJ McKay on 9/13/18.
//

import Foundation
import Leaf


public final class ConfigValue: TagRenderer {
    let domain = "http://localhost:8080/"
    /// Creates a new `ValueForField` tag renderer.
    public init() {}
    
    /// See `TagRenderer`.
    public func render(tag: TagContext) throws -> Future<TemplateData> {
        /// Require at least one parameter.
        switch tag.parameters.count {
        case 1: break
        default: throw tag.error(reason: "Invalid parameter count: \(tag.parameters.count). 2 required.")
        }
        let configs: [String: String] = ["domain": domain,
                                         "inviteURL": domain+"invite/"]
        let fieldName = tag.parameters[0].string ?? ""
        let value = configs[fieldName] ?? ""
        /// Return formatted date
        return Future.map(on: tag) { .string(value) }
    }
    
}
