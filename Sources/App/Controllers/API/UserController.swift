import Vapor
import Crypto

struct UsersController: KaminoController {
    
    
    typealias T = User
    typealias Public = User.Public
    static var path = "users"
    
    func boot(router: Router) throws {
        let usersRoute = router.grouped(KaminoApi.path, UsersController.path)
//        usersRoute.post(User.self, use: createHandler)
//        usersRoute.get(use: getAllHandler)
//        usersRoute.get(User.parameter, use: getAllHandler)
//        let basicAuthMiddleware = User.basicAuthMiddleware(using: BCryptDigest())
//        let basicAuthGroup = usersRoute.grouped(basicAuthMiddleware)
//        basicAuthGroup.post("login", use: loginHandler)
//        
//        let tokenAuthMiddleware = User.tokenAuthMiddleware()
//        let guardAuthMiddleware = User.guardAuthMiddleware()
//        let tokenAuthGroup = usersRoute.grouped(tokenAuthMiddleware, guardAuthMiddleware)
//        tokenAuthGroup.post(User.self, use: createHandler)
//        tokenAuthGroup.get(use: getAllHandler)
//        tokenAuthGroup.get(User.parameter, use: getAllHandler)
        
        let protectedRoutes = usersRoute.grouped(JWTMiddleWareProvider())
        protectedRoutes.post(User.self, use: createHandler)
        protectedRoutes.get(use: getAllHandler)
        protectedRoutes.get(User.parameter, use: getAllHandler)
        
    }
    
    func createHandler(_ req: Request, entity: User) throws -> Future<Public> {
        entity.password = try BCrypt.hash(entity.password)
        return entity.save(on: req).convertToPublic()
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[Public]> {
        return T.query(on: req).decode(data: Public.self).all()
    }
    
    func getHandler(_ req: Request) throws -> Future<Public> {
        return try req.parameters.next(User.self).convertToPublic()
    }
    
    func loginHandler(_ req: Request) throws -> Future<Token> {
        let user = try req.requireAuthenticated(User.self)
        let token = try Token.generate(for: user)
        return token.save(on: req)
    }
    
    func updateHandler(_ req: Request) throws -> EventLoopFuture<User.Public> {
        return try flatMap(to: T.Public.self,
                           req.parameters.next(T.self),
                           req.content.decode(T.self)) { item, updatedItem in
                            item.password = try BCrypt.hash(item.password)
                            //                            item.short = updatedItem.short
                            //                            item.long = updatedItem.long
                            return item.save(on: req).convertToPublic()
        }
    }
    
    func deleteHandler(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return try req.parameters.next(T.self).delete(on: req).transform(to: HTTPStatus.noContent)
    }
    
    
    
}
