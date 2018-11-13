//
//  VerifyEmail.swift
//  App
//
//  Created by DJ McKay on 9/13/18.
//

import Foundation
import Vapor
import Authentication
import FluentMySQL

final class VerifyEmail: KaminoModel {
    var id: UUID?
    var userId: User.ID
    var verified: Bool
    var createdAt: Date?
    var updatedAt: Date?
    typealias Public = VerifyEmail
    
    init(userId: User.ID) {
        self.userId = userId
        self.verified = false
    }
    
    func convertToPublic() -> VerifyEmail {
        return self
    }
}

extension VerifyEmail: Migration {
    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.userId, to: \User.id)
        }
    }
}

extension VerifyEmail: Content {}

extension VerifyEmail {
    static var createdAtKey: TimestampKey? = \.createdAt
    static var updatedAtKey: TimestampKey? = \.updatedAt
}
