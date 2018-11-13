//
//  CountryController.swift
//  App
//
//  Created by DJ McKay on 9/7/18.
//

import Foundation
import Vapor
import Crypto

struct CountryController: KaminoController {
    
    
    
    typealias T = Country
    typealias Public = Country
    static var path = "countries"
    
    func boot(router: Router) throws {
        let route = router.grouped(KaminoApi.path, CountryController.path)
        route.get(Country.parameter, use: getHandler)
        route.get(use: getAllHandler)
        route.get(Country.parameter, "zones", use: getZonesHandler)
        
    }
    
    func getHandler(_ req: Request) throws -> Future<Public> {
        return try req.parameters.next(Country.self).convertToPublic()
    }
    
    func getZonesHandler(_ req: Request) throws -> Future<[Zone.Public]> {
        return try req.parameters.next(Country.self).flatMap(to: [Zone.Public].self, { (country)  in
            try country.zones.query(on: req).all()
        })
    }
    
    func createHandler(_ req: Request, entity: Country) throws -> EventLoopFuture<Country.Public> {
        return entity.save(on: req).convertToPublic()
    }
    
    func getAllHandler(_ req: Request) throws -> EventLoopFuture<[Country.Public]> {
        return T.query(on: req).decode(data: Public.self).all()
    }
    
    func updateHandler(_ req: Request) throws -> EventLoopFuture<Public> {
        return try flatMap(to: T.self,
                           req.parameters.next(T.self),
                           req.content.decode(T.self)) { item, updatedItem in
                            //                            item.short = updatedItem.short
                            //                            item.long = updatedItem.long
                            return item.save(on: req)
        }
    }
    
    func deleteHandler(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return try req.parameters.next(T.self).delete(on: req).transform(to: HTTPStatus.noContent)
    }
    
    
    
    
}
