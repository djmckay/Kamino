//
//  UserMigrations.swift
//  App
//
//  Created by DJ McKay on 9/7/18.
//

import Foundation
import Vapor
import FluentMySQL
import Authentication

//struct AdminUser: Migration {
//    static func prepare(on conn: MySQLConnection) -> EventLoopFuture<Void> {
//        let password = try? BCrypt.hash("password")
//        guard let hashedPassword = password else {
//            fatalError("Failed to create admin user")
//        }
//        
//        let user = User(name: "Admin", username: "admin", password: hashedPassword, organization: "Kamino", account: 0, isOrganizer: true)
//        return user.save(on: conn).transform(to: ())
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

struct AddIsOrganizer: Migration {
    static func prepare(on conn: MySQLConnection) -> EventLoopFuture<Void> {
        return MySQLDatabase.update(User.self, on: conn, closure: { (builder) in
            builder.field(for: \.isOrganizer)
        })
    }
    
    static func revert(on conn: MySQLConnection) -> EventLoopFuture<Void> {
        return MySQLDatabase.update(User.self, on: conn, closure: { (builder) in
            builder.deleteField(for: \.isOrganizer)
        })
    }
    
    typealias Database = MySQLDatabase
    
    
}

struct AddAccountId: Migration {
    static func prepare(on conn: MySQLConnection) -> EventLoopFuture<Void> {
        return MySQLDatabase.update(User.self, on: conn, closure: { (builder) in
            builder.field(for: \.account)
        })
    }
    
    static func revert(on conn: MySQLConnection) -> EventLoopFuture<Void> {
        return MySQLDatabase.update(User.self, on: conn, closure: { (builder) in
            builder.deleteField(for: \.account)
        })
    }
    
    typealias Database = MySQLDatabase
    
    
}

struct RenameAccountId: Migration {
    static func prepare(on conn: MySQLConnection) -> EventLoopFuture<Void> {
        return MySQLDatabase.update(User.self, on: conn, closure: { (builder) in
            builder.field(for: \.accountId)
        })
    }
    
    static func revert(on conn: MySQLConnection) -> EventLoopFuture<Void> {
        return MySQLDatabase.update(User.self, on: conn, closure: { (builder) in
            builder.deleteField(for: \.account)
        })
    }
    
    typealias Database = MySQLDatabase
    
    
}

struct AddAccountReferenceUser: Migration {
    static func prepare(on conn: MySQLConnection) -> EventLoopFuture<Void> {
        return MySQLDatabase.update(User.self, on: conn, closure: { (builder) in
            builder.reference(from: \.accountId, to: \Account.id)
        })
    }
    
    static func revert(on conn: MySQLConnection) -> EventLoopFuture<Void> {
        return .done(on: conn)
    }
    
    typealias Database = MySQLDatabase
    
    
}


