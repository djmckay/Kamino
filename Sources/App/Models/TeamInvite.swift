//
//  TeamInvite.swift
//  App
//
//  Created by DJ McKay on 9/13/18.
//

import Foundation
import Vapor
import Authentication
import FluentMySQL

final class TeamInvite: KaminoModel {
    var id: UUID?
    var accountId: Account.ID
    var createdAt: Date?
    var updatedAt: Date?
    typealias Public = TeamInvite
    
    init(accountId: Account.ID) {
        self.accountId = accountId
    }
    
    func convertToPublic() -> TeamInvite {
        return self
    }
}

extension TeamInvite: Migration {
    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.accountId, to: \Account.id)
        }
    }
}

extension TeamInvite: Content {}

extension TeamInvite {
    static var createdAtKey: TimestampKey? = \.createdAt
    static var updatedAtKey: TimestampKey? = \.updatedAt
}


