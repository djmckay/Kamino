//
//  BasicAttendee.swift
//  App
//
//  Created by DJ McKay on 9/18/18.
//

import Foundation
import Vapor
import FluentMySQL
import Authentication

final class BasicAttendee: KaminoModel {
    var id: UUID? {
        get {
            return minimalistAttendee.id
        }
        set {
            self.minimalistAttendee.id = newValue
        }
    }
    
    
    var minimalistAttendee: MinimalistAttendee
    var phone: String
    var organization: String
    var createdAt: Date?
    var updatedAt: Date?
    
    typealias Public = BasicAttendee
}

extension BasicAttendee: Content {}
extension BasicAttendee {
    static var createdAtKey: TimestampKey? = \minimalistAttendee.createdAt
    static var updatedAtKey: TimestampKey? = \minimalistAttendee.updatedAt
}

extension BasicAttendee: Parameter {}


extension BasicAttendee {
    func convertToPublic() -> BasicAttendee.Public {
        return self
    }
}

extension Future where T: BasicAttendee {
    func convertToPublic() -> Future<BasicAttendee.Public> {
        return self.map(to: BasicAttendee.Public.self, { (attendee) -> BasicAttendee.Public in
            return attendee.convertToPublic()
        })
    }
}

extension BasicAttendee {
    public func save(on req: Request) -> Future<BasicAttendee> {
        
        return self.minimalistAttendee.save(on: req).flatMap(to: BasicAttendee.self) { (minimalist) -> EventLoopFuture<BasicAttendee> in
            return BasicAttendee.query(on: req).save(self)
        }
    }
}

