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
    
    init(name: String, iso_code_2: String, iso_code_3: String, address_format: String, postcode_required: Bool, status: Bool) {
        self.name = name
        self.iso_code_2 = iso_code_2
        self.iso_code_3 = iso_code_3
        self.address_format = address_format
        self.postcode_required = postcode_required
        self.status = status
        
    }
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
