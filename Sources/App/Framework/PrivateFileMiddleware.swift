//
//  PrivateFileMiddleware.swift
//  App
//
//  Created by DJ McKay on 9/13/18.
//

import Foundation
import Vapor
public final class PrivateFileMiddleware: Middleware, ServiceType {
    /// See `ServiceType`.
    public static func makeService(for container: Container) throws -> PrivateFileMiddleware {
        return try .init(privateDirectory: container.make(DirectoryConfig.self).workDir + "Private/")
    }
    
    /// The public directory.
    /// - note: Must end with a slash.
    private let privateDirectory: String
    
    /// Creates a new `FileMiddleware`.
    public init(privateDirectory: String) {
        self.privateDirectory = privateDirectory.hasSuffix("/") ? privateDirectory : privateDirectory + "/"
    }
    
    /// See `Middleware`.
    public func respond(to req: Request, chainingTo next: Responder) throws -> Future<Response> {
        // make a copy of the path
        var path = req.http.url.path
        
        // path must be relative.
        while path.hasPrefix("/") {
            path = String(path.dropFirst())
        }
        
        // protect against relative paths
        guard !path.contains("../") else {
            throw Abort(.forbidden)
        }
        
        // create absolute file path
        let filePath = privateDirectory + path
        
        // check if file exists and is not a directory
        var isDir: ObjCBool = false
        guard FileManager.default.fileExists(atPath: filePath, isDirectory: &isDir), !isDir.boolValue else {
            return try next.respond(to: req)
        }
        
        // stream the file
        return try req.streamFile(at: filePath)
    }
}

