//
//  EventMigrations.swift
//  App
//
//  Created by DJ McKay on 9/8/18.
//

import Foundation
import Vapor
import FluentMySQL
import Authentication


struct EventAccountMigration: Migration {
    static func prepare(on conn: MySQLConnection) -> EventLoopFuture<Void> {
        return MySQLDatabase.update(Event.self, on: conn, closure: { (builder) in
            builder.field(for: \.accountId)
            builder.field(for: \.userId)
        })
    }
    
    static func revert(on conn: MySQLConnection) -> EventLoopFuture<Void> {
        return MySQLDatabase.update(Event.self, on: conn, closure: { (builder) in
            builder.deleteField(for: \.accountId)
            builder.deleteField(for: \.userId)
        })
    }
    
    typealias Database = MySQLDatabase
    
    
}

//struct AddUniqueIdEvent: Migration {
//    static func prepare(on conn: MySQLConnection) -> EventLoopFuture<Void> {
//        return MySQLDatabase.update(Event.self, on: conn, closure: { (builder) in
//            builder.field(for: \.uuid)
//        })
//    }
//    
//    static func revert(on conn: MySQLConnection) -> EventLoopFuture<Void> {
//        return MySQLDatabase.update(Event.self, on: conn, closure: { (builder) in
//            return builder.deleteField(for: \.uuid)
//        })
//    }
//    
//    typealias Database = MySQLDatabase
//    
//    
//}

struct AddCreatedAtUpdateAtEvent: Migration {
    static func prepare(on conn: MySQLConnection) -> EventLoopFuture<Void> {
        return MySQLDatabase.update(Event.self, on: conn, closure: { (builder) in
            builder.field(for: \.createdAt)
            builder.field(for: \.updatedAt)
        })
    }
    
    static func revert(on conn: MySQLConnection) -> EventLoopFuture<Void> {
        return MySQLDatabase.update(Event.self, on: conn, closure: { (builder) in
            builder.deleteField(for: \.createdAt)
            builder.deleteField(for: \.updatedAt)
        })
    }
    
    typealias Database = MySQLDatabase
    
    
}

struct AddLastUpdatedByUser: Migration {
    static func prepare(on conn: MySQLConnection) -> EventLoopFuture<Void> {
        return MySQLDatabase.update(Event.self, on: conn, closure: { (builder) in
            builder.field(for: \.lastUpdateUserId)
        })
    }
    
    static func revert(on conn: MySQLConnection) -> EventLoopFuture<Void> {
        return MySQLDatabase.update(Event.self, on: conn, closure: { (builder) in
            builder.deleteField(for: \.lastUpdateUserId)
        })
    }
    
    typealias Database = MySQLDatabase
    
    
}

struct AddAccountReferenceEvent: Migration {
    static func prepare(on conn: MySQLConnection) -> EventLoopFuture<Void> {
        return MySQLDatabase.update(Event.self, on: conn, closure: { (builder) in
            builder.reference(from: \.accountId, to: \Account.id)
        })
    }
    
    static func revert(on conn: MySQLConnection) -> EventLoopFuture<Void> {
        return .done(on: conn)
    }
    
    typealias Database = MySQLDatabase
    
    
}

struct AddUserReferenceEvent: Migration {
    static func prepare(on conn: MySQLConnection) -> EventLoopFuture<Void> {
        return MySQLDatabase.update(Event.self, on: conn, closure: { (builder) in
            builder.reference(from: \.userId, to: \User.id)
        })
    }
    
    static func revert(on conn: MySQLConnection) -> EventLoopFuture<Void> {
        return .done(on: conn)
    }
    
    typealias Database = MySQLDatabase
    
    
}
