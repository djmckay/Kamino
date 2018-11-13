//
//  AccountMigrations.swift
//  App
//
//  Created by DJ McKay on 9/7/18.
//

import Foundation
import Vapor
import FluentMySQL
import Authentication

extension Account: Migration {
    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return Database.create(self, on: connection, closure: { (builder) in
            try addProperties(to: builder)
            builder.unique(on: \.name)
        })
    }
    
}

//struct MasterAccount: Migration {
//    static func prepare(on conn: MySQLConnection) -> EventLoopFuture<Void> {
//        let password = try? BCrypt.hash("password")
//        guard let hashedPassword = password else {
//            fatalError("Failed to create admin user")
//        }
//        let account = Account(name: "Kamino")
//        return account.save(on: conn).flatMap({ (account)  in
//            let user = User(name: "Admin", username: "admin", password: hashedPassword, organization: account.name, account: account.id!, isOrganizer: true)
//            return user.save(on: conn).transform(to: ())
//        })
//    }
//    
//    static func revert(on conn: MySQLConnection) -> EventLoopFuture<Void> {
//        return .done(on: conn)
//    }
//    
//    typealias Database = MySQLDatabase
//    
//    
//}
