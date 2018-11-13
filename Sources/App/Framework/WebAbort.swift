//
//  WebAbort.swift
//  App
//
//  Created by DJ McKay on 9/13/18.
//

import Foundation
import Vapor

public struct WebAbort: AbortError {
    var abort: Abort!
    public var status: HTTPResponseStatus {
        get {
            return abort.status
        }
        set {
            abort.status = newValue
        }
    }
    
    public var identifier: String {
        get {
             return abort.identifier
        }
        set {
            abort.identifier = newValue
        }
    }
    
    public var reason: String {
        get {
            return abort.reason
        }
        set {
            abort.reason = newValue
        }
    }
    public var errorMessage: String?
    
    // Creates a redirecting `Abort` error.
    ///
    ///     throw Abort.redirect(to: "https://vapor.codes")"
    ///
    /// Set type to '.permanently' to allow caching to automatically redirect from browsers.
    /// Defaulting to non-permanent to prevent unexpected caching.
    public static func errorPage(_ status: HTTPResponseStatus, errorMessage: String? = nil) -> WebAbort {
        let abort = Abort.redirect(to: "/error", type: .normal)
        return .init(abort: abort, errorMessage)
    }
    
    public init(abort: Abort, _ errorMessage: String?) {
        self.abort = abort
        self.errorMessage = errorMessage
    }
    
    public init(
        _ status: HTTPResponseStatus,
        headers: HTTPHeaders = [:],
        reason: String? = nil
        ) {
        self.abort = Abort(status, headers: headers, reason: reason)
    }
    
}
