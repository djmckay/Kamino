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

final class MinimalistAttendee: KaminoModel {
    var id: UUID?
    var firstname: String
    var lastName: String
    var email: String
    var phone: String
    var organization: String
    var eventId: Event.ID
    var createdAt: Date?
    var updatedAt: Date?
    
    typealias Public = MinimalistAttendee
}

extension MinimalistAttendee: Content {}
extension MinimalistAttendee {
    static var createdAtKey: TimestampKey? = \.createdAt
    static var updatedAtKey: TimestampKey? = \.updatedAt
}

extension MinimalistAttendee: Parameter {}


extension MinimalistAttendee {
    func convertToPublic() -> MinimalistAttendee.Public {
        return self
    }
}

extension Future where T: MinimalistAttendee {
    func convertToPublic() -> Future<MinimalistAttendee.Public> {
        return self.map(to: MinimalistAttendee.Public.self, { (attendee) -> MinimalistAttendee.Public in
            return attendee.convertToPublic()
        })
    }
}


