//
//  Account.swift
//  App
//
//  Created by DJ McKay on 9/7/18.
//

import Foundation
import Vapor
import FluentMySQL
import Authentication


final class Account: KaminoModel {
    
    typealias Public = Account
    
    var id: UUID?
    var name: String

    func convertToPublic() -> Account {
        return self
    }
    
    init(name: String) {
        self.name = name
    }
}

extension Account: Parameter {}

extension Account.Public: Content {}

extension Account {
    var users: Children<Account, User> {
        return children(\.accountId)
    }
}

extension Account {
    var events: Children<Account, Event> {
        return children(\.accountId)
    }
}

extension Future where T: Account {
    func convertToPublic() -> Future<Account.Public> {
        return self.map(to: Account.Public.self, { (account) -> Account.Public in
            return account.convertToPublic()
        })
    }
}

//Create special token?
//extension Account: TokenAuthenticatable {
//    typealias TokenType = Token
//}


