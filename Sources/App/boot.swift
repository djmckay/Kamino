import Vapor
import FluentMySQL

/// Called after your application has initialized.
public func boot(_ app: Application) throws {
    // your code here
    
    _ = app.withNewConnection(to: .mysql) { (conn: MySQLDatabase.Connection)  in
        return conn.query("CREATE DATABASE IF NOT EXISTS Coruscant")
    }
}
