//
//  Zone.swift
//  App
//
//  Created by DJ McKay on 9/6/18.
//

import Foundation
import Vapor
import FluentMySQL
import Authentication

final class Zone: MySQLModel {
    
    typealias Public = Zone
    
    
    var id: Int?
    var country_id: Country.ID
    var name: String
    var code: String
    var status: Bool
    
    init(country_id: Count.ID, name: String, code: String, status: Bool) {
        self.country_id = country_id
        self.name = name
        self.code = code
        self.status = status
    }
    
    func convertToPublic() -> Zone {
        return self
    }
    
}

extension Zone: Content {}
extension Zone: Migration {}
extension Zone: Parameter {}

extension Zone {
    var country: Parent<Zone, Country> {
        return parent(\.country_id)
    }
}

extension Future where T: Zone {
    func convertToPublic() -> Future<Zone.Public> {
        return self.map(to: Zone.Public.self, { (user) -> Zone.Public in
            return user.convertToPublic()
        })
    }
}
