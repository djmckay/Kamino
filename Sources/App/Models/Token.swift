//
//  Token.swift
//  App
//
//  Created by DJ McKay on 9/6/18.
//

import Foundation
import Vapor
import Authentication
import FluentMySQL

final class Token: KaminoModel {
    
    var id: UUID?
    var token: String
    var userID: User.ID
    typealias Public = Token
    
    init(token: String, userID: User.ID) {
        self.token = token
        self.userID = userID
    }
    
    func convertToPublic() -> Token {
        return self
    }
}

extension Token: Migration {
    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.userID, to: \User.id)
        }
    }
}

extension Token: Content {}

extension Token {
    static func generate(for user: User) throws -> Token {
        let random = try CryptoRandom().generateData(count: 16)
        return try Token(token: random.base64EncodedString(),
                         userID: user.requireID())
    }
}

extension Token: Authentication.Token {
    static let userIDKey: UserIDKey = \Token.userID
    typealias UserType = User
    typealias UserIDType = User.ID
}

extension Token: BearerAuthenticatable {
    static let tokenKey: TokenKey = \Token.token
}

