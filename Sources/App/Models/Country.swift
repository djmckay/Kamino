//
//  Country.swift
//  App
//
//  Created by DJ McKay on 9/6/18.
//

import Foundation
import Vapor
import FluentMySQL
import Authentication

final class Country: MySQLModel {
    
    typealias Public = Country
    
    
    var id: Int?
    var name: String
    var iso_code_2: String
    var iso_code_3: String
    var address_format: String
    var postcode_required: Bool = false
    var status: Bool
    
    func convertToPublic() -> Country {
        return self
    }
    
}

extension Country: Content {}
extension Country: Migration {}
extension Country: Parameter {}

extension Country {
    var zones: Children<Country, Zone> {
        return children(\.country_id)
    }
}

extension Future where T: Country {
    func convertToPublic() -> Future<Country.Public> {
        return self.map(to: Country.Public.self, { (user) -> Country.Public in
            return user.convertToPublic()
        })
    }
}
