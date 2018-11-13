//
//  PrintHTML.swift
//  App
//
//  Created by DJ McKay on 9/14/18.
//

import Foundation
import Leaf

public final class PrintHTML: TagRenderer {
    /// Creates a new `Print` tag renderer.
    public init() { }
    
    /// See `TagRenderer`.
    public func render(tag: TagContext) throws -> Future<TemplateData> {
        try tag.requireNoBody()
        try tag.requireParameterCount(1)
        let string = tag.parameters[0].string ?? ""
        return Future.map(on: tag) { .string(string) }
    }
}
