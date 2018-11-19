//
//  System.swift
//  App
//
//  Created by DJ McKay on 9/5/18.
//

import Foundation
import Vapor
import FluentMySQL

struct Kamino {
    static fileprivate let DatabaseHost: String = Environment.get("DATABASE_HOSTNAME") ?? "10.0.1.9"
    static fileprivate let DatabaseUsername: String = Environment.get("DATABASE_USER") ?? "user"
    static let DatabaseName: String = Environment.get("DATABASE_DB") ?? "Coruscant"
    static fileprivate let DatabasePassword: String = Environment.get("DATABASE_PASSWORD") ?? "pword"
    
    static let CoruscantConfig = MySQLDatabaseConfig(hostname: DatabaseHost, port: 3306, username: DatabaseUsername, password: DatabasePassword, database: DatabaseName)
    static let Coruscant = MySQLDatabase(config: CoruscantConfig)
}

extension DatabaseIdentifier {
    /// Default identifier for `MySQLDatabase`.
    public static var Coruscant: DatabaseIdentifier<MySQLDatabase> {
        return .init("Coruscant")
    }
}
