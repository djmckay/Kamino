//
//  EmailAddress.swift
//  Mailgun
//
//  Created by Andrew Edwards on 3/29/18.
//

import Vapor

public struct EmailAddress: Content {
    /// format: "Bob <bob@host.com>"
    public var email: String?
    
    
    public init(email: String,
                name: String? = nil) {
        self.email = "\(name ?? "") <\(email)>"
    }
}
