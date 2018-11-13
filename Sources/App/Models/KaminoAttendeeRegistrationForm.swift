//
//  KaminoAttendeeRegistrationForm.swift
//  App
//
//  Created by DJ McKay on 9/14/18.
//

import Foundation
import Vapor
import Authentication
import FluentMySQL

final class KaminoAttendeeRegistrationForm: KaminoModel {
    var id: UUID?
    var leafName: String
    var description: String
    var sortOrder: Int = 0
    var createdAt: Date?
    var updatedAt: Date?
    typealias Public = KaminoAttendeeRegistrationForm
    
    init(leafName: String, description: String) {
        self.leafName = leafName
        self.description = description
    }
    
    func convertToPublic() -> KaminoAttendeeRegistrationForm {
        return self
    }
}

extension KaminoAttendeeRegistrationForm: Migration {
    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.leafName)
            builder.field(for: \.sortOrder)
            builder.field(for: \.description)
            builder.field(for: \.createdAt)
            builder.field(for: \.updatedAt)
//            builder.reference(from: \.userId, to: \User.id)
        }
    }
}

extension KaminoAttendeeRegistrationForm: Content {}
extension KaminoAttendeeRegistrationForm: Parameter {}

extension Future where T: KaminoAttendeeRegistrationForm {
    func convertToPublic() -> Future<KaminoAttendeeRegistrationForm.Public> {
        return self.map(to: KaminoAttendeeRegistrationForm.Public.self, { (form) -> KaminoAttendeeRegistrationForm.Public in
            return form.convertToPublic()
        })
    }
}

extension KaminoAttendeeRegistrationForm {
    static var createdAtKey: TimestampKey? = \.createdAt
    static var updatedAtKey: TimestampKey? = \.updatedAt
}
