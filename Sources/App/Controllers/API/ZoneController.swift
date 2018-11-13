//
//  ZoneController.swift
//  App
//
//  Created by DJ McKay on 9/7/18.
//

import Foundation
import Vapor
import Crypto

struct ZonesController: KaminoController {
    
    
    typealias T = Zone
    typealias Public = Zone
    static var path = "zones"
    
    func boot(router: Router) throws {
        let route = router.grouped(KaminoApi.path, ZonesController.path)
        route.get(Zone.parameter, use: getHandler)
        route.get(use: getAllHandler)
    }
    
    func getHandler(_ req: Request) throws -> Future<Public> {
        return try req.parameters.next(Zone.self).convertToPublic()
    }
    
    func createHandler(_ req: Request, entity: Zone) throws -> EventLoopFuture<Zone.Public> {
        return entity.save(on: req).convertToPublic()
    }
    
    func getAllHandler(_ req: Request) throws -> EventLoopFuture<[Zone.Public]> {
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
