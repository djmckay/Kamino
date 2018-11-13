//
//  Event.swift
//  App
//
//  Created by DJ McKay on 9/6/18.
//

import Foundation
import Vapor
import FluentMySQL
import Authentication

final class Event: KaminoUserTrackable {
    
    static let dateFormatter: DateFormatter = {
        let instance = DateFormatter()
        // setup code
        instance.dateFormat = "MM/dd/yyyy"
        return instance
    }()
    
    var id: UUID?
    var uuid: UUID
    var name: String
    var password: String
    var startDate: Date
    var endDate: Date
    var logoFilename: String?
    var description: String?
    var locationName: String?
    var locationPhone: String?
    var eventPhone: String?
    var locationAddress: String?
    var locationAddressLine2: String?
    var locationCity: String?
    var locationState: String?
    var locationCountry: String?
    var locationPostalCode: String?
    var accountId: Account.ID
    var userId: User.ID
    var lastUpdateUserId: User.ID
    
    var createdAt: Date?
    var updatedAt: Date?
    
    init(name: String, password: String, startDate: Date, endDate: Date, user: User) {
        self.name = name
        self.password = password
        self.startDate = startDate
        self.endDate = endDate
        self.accountId = user.accountId
        self.userId = user.id!
        self.uuid = UUID()
        self.lastUpdateUserId = user.id!
    }
    
    final class Public: Codable {
        var id: Event.ID?
        var name: String
        
        init(id: Event.ID?, name: String) {
            self.id = id
            self.name = name
        }
    }
    
    
    
}

extension Event {
    func convertToPublic() -> Event.Public {
        return Event.Public(id: id, name: name)
    }
}

extension Future where T: Event {
    func convertToPublic() -> Future<Event.Public> {
        return self.map(to: Event.Public.self, { (event) -> Event.Public in
            return event.convertToPublic()
        })
    }
}
extension Event: Content {}
extension Event: Migration {}
extension Event: Parameter {}

extension Event {
    
}

extension Event {
    var account: Parent<Event, Account> {
        return parent(\.accountId)
    }
}

extension Event {
    var user: Parent<Event, User> {
        return parent(\.userId)
    }
}

extension Event {
    static var createdAtKey: TimestampKey? = \.createdAt
    static var updatedAtKey: TimestampKey? = \.updatedAt
}

extension Event {
    public func save(on req: Request) -> Future<Event> {
        do {
            let user = try req.requireAuthenticated(User.self)
            self.lastUpdateUserId = user.id!
        } catch {
            
        }
        return Event.query(on: req).save(self)
    }
}

extension Event {
    var attendees: Children<Event, MinimalistAttendee> {
        return children(\.eventId)
    }
}
