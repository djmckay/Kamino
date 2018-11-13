//
//  AccountController.swift
//  App
//
//  Created by DJ McKay on 9/7/18.
//

import Foundation
import Vapor
import JWT

struct AccountController: KaminoController {
    
    
    static var path: String = "accounts"
    
    func createHandler(_ req: Request, entity: Account) throws -> EventLoopFuture<Account> {
        return entity.save(on: req).convertToPublic()
    }
    
    func getAllHandler(_ req: Request) throws -> EventLoopFuture<[Account]> {
        return T.query(on: req).decode(data: Public.self).all()
    }
    
    func getHandler(_ req: Request) throws -> EventLoopFuture<Account> {
        return try req.parameters.next(Account.self).convertToPublic()
    }
    
    typealias T = Account
    
    typealias Public = Account
    
    func boot(router: Router) throws {
        let route = router.grouped(KaminoApi.path, AccountController.path)
        
        let protectedRoutes = route.grouped(JWTMiddleWareProvider())
        protectedRoutes.get(Account.parameter, use: getHandler)
        protectedRoutes.get(use: getAllHandler)
        protectedRoutes.get(Account.parameter, "users", use: getUsersHandler)
        
    }
    
    func getUsersHandler(_ req: Request) throws -> Future<[User.Public]> {
        return try req.parameters.next(Account.self).flatMap(to: [User.Public].self, { (account)  in
            try account.users.query(on: req).decode(data: User.Public.self).all()
        })
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


struct AdminToken: JWTPayload {
    var name: String
    var key: String
    
    func verify(using signer: JWTSigner) throws {
        // nothing to verify
        print("nothing to verify")
        print(self.key)
    }
}

class JWTMiddleWareProvider: Middleware {
    func respond(to request: Request, chainingTo next: Responder) throws -> EventLoopFuture<Response> {
        guard let bearer = request.http.headers.bearerAuthorization else {
            throw Abort(.unauthorized)
        }
        // parse JWT from token string, using HS-256 signer
        let token = try JWT<AdminToken>(from: bearer.token, verifiedUsing: .hs256(key: "secret"))

        return try next.respond(to: request)
    
    }
}
