//
//  AttendeeAddress.swift
//  App
//
//  Created by DJ McKay on 9/18/18.
//

import Foundation
import Vapor
import FluentMySQL
import Authentication

final class AttendeeAddress: KaminoModel {
    var id: UUID?
    var addressLine1: String
    var addressLine2: String
    var city: String
    var zoneId: Zone.ID
    var postalCode: String
    var createdAt: Date?
    var updatedAt: Date?
    
    typealias Public = AttendeeAddress
}

extension AttendeeAddress: Content {}
extension AttendeeAddress {
    static var createdAtKey: TimestampKey? = \.createdAt
    static var updatedAtKey: TimestampKey? = \.updatedAt
}

extension AttendeeAddress: Parameter {}


extension AttendeeAddress {
    func convertToPublic() -> AttendeeAddress.Public {
        return self
    }
}

extension Future where T: AttendeeAddress {
    func convertToPublic() -> Future<AttendeeAddress.Public> {
        return self.map(to: AttendeeAddress.Public.self, { (attendee) -> AttendeeAddress.Public in
            return attendee.convertToPublic()
        })
    }
}

extension AttendeeAddress {
    var user: Parent<AttendeeAddress, Zone> {
        return parent(\.zoneId)
    }
}


