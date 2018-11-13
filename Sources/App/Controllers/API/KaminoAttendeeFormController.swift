//
//  KaminoAttendeeFormController.swift
//  App
//
//  Created by DJ McKay on 9/14/18.
//

import Foundation
import Vapor
import JWT

struct KaminoAttendeeFormController: KaminoController {
    
    
    typealias T = KaminoAttendeeRegistrationForm
    typealias Public = KaminoAttendeeRegistrationForm
    static var path = "kaminoAttendeeRegistrationForms"
    
    func boot(router: Router) throws {
        let route = router.grouped(KaminoApi.path, KaminoAttendeeFormController.path)
        let protectedRoutes = route.grouped(JWTMiddleWareProvider())
        protectedRoutes.get(KaminoAttendeeRegistrationForm.parameter, use: getHandler)
        protectedRoutes.get(use: getAllHandler)
        protectedRoutes.post(KaminoAttendeeRegistrationForm.self, use: createHandler)
        protectedRoutes.put(KaminoAttendeeRegistrationForm.parameter, use: updateHandler)
        protectedRoutes.delete(KaminoAttendeeRegistrationForm.parameter, use: deleteHandler)

    }
    
    func getHandler(_ req: Request) throws -> Future<Public> {
        return try req.parameters.next(KaminoAttendeeRegistrationForm.self).convertToPublic()
    }
    
    func createHandler(_ req: Request, entity: KaminoAttendeeRegistrationForm) throws -> EventLoopFuture<KaminoAttendeeRegistrationForm.Public> {
        return entity.save(on: req).convertToPublic()
    }
    
    func getAllHandler(_ req: Request) throws -> EventLoopFuture<[KaminoAttendeeRegistrationForm.Public]> {
        return KaminoAttendeeRegistrationForm.query(on: req).decode(data: KaminoAttendeeRegistrationForm.Public.self).all()
    }
    
    func updateHandler(_ req: Request) throws -> EventLoopFuture<Public> {
        return try flatMap(to: T.self,
                           req.parameters.next(T.self),
                           req.content.decode(T.self)) { item, updatedItem in
                            item.leafName = updatedItem.leafName
                            item.description = updatedItem.description
                            item.sortOrder = updatedItem.sortOrder
                            //                            item.short = updatedItem.short
                            //                            item.long = updatedItem.long
                            return item.save(on: req)
        }
    }
    func deleteHandler(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return try req.parameters.next(T.self).delete(on: req).transform(to: HTTPStatus.noContent)
    }
    
    
}
