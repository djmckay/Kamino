//
//  Users.swift
//  App
//
//  Created by DJ McKay on 9/5/18.
//

import Foundation
import Vapor
import FluentMySQL
import Authentication

final class User: KaminoModel {
    var id: UUID?
    var name: String
    var organization: String
    var accountId: Account.ID
    var username: String
    var password: String
    var isOrganizer: Bool
    
    init(name: String, username: String, password: String, organization: String, account: Account.ID, isOrganizer: Bool) {
        self.name = name
        self.username = username
        self.password = password
        self.organization = organization
        self.accountId = account
        self.isOrganizer = isOrganizer
    }
    
    final class Public: Codable {
        var id: UUID?
        var name: String
        var username: String
        var organization: String
        var accountId: Account.ID
        var isOrganizer: Bool
        init(id: User.ID?, name: String, username: String, organization: String, account: Account.ID, isOrganizer: Bool) {
            self.id = id
            self.name = name
            self.username = username
            self.organization = organization
            self.accountId = account
            self.isOrganizer = isOrganizer
        }
    }
}

extension User: Content {}
extension User: Migration {
    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return Database.create(self, on: connection, closure: { (builder) in
            try addProperties(to: builder)
            builder.unique(on: \.username)
        })
    }
    
}
extension User: Parameter {}

extension User.Public: Content {}

extension User {
    func convertToPublic() -> User.Public {
        return User.Public(id: id, name: name, username: username, organization: organization, account: accountId, isOrganizer: isOrganizer)
    }
}

extension Future where T: User {
    func convertToPublic() -> Future<User.Public> {
        return self.map(to: User.Public.self, { (user) -> User.Public in
            return user.convertToPublic()
        })
    }
}

extension User: BasicAuthenticatable {
    static let usernameKey: UsernameKey = \User.username
    static let passwordKey: PasswordKey = \User.password
    
}

extension User: TokenAuthenticatable {
    typealias TokenType = Token
}




extension User: PasswordAuthenticatable {}

extension User: SessionAuthenticatable {}

extension User {
    var account: Parent<User, Account> {
        return parent(\.accountId)
    }
}

extension User {
    var events: Children<User, Event> {
        return children(\.userId)
    }
}

//this doesn't work with validation framework...not future based.
extension User: KaminoDatabaseValidatable, Reflectable {
    static func validations(conn: DatabaseConnectable) throws -> KaminoDBValidations<User> {
        var validations = KaminoDBValidations(User.self)
        validations.add("user unique") { (user) in
            let existing = User.query(on: conn).filter(\.username == user.username)
//            if (try existing.first().wait()) != nil {
//                throw KaminoBasicValidationError("user not unique", "username")
//            }
            return existing.first().map(to: Void.self, { (user)  in
                if user != nil {
                    throw KaminoBasicValidationError("user not unique", "username")
                }
            }).map(to: Void.self, { ()  in
                return
            })
        }
        return validations
    }
    
    static func validations() throws -> KaminoValidations<User> {
        let validations = KaminoValidations(User.self)
        
        return validations
    }
    
}
