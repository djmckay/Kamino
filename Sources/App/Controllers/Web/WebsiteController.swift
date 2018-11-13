//
//  WebsiteController.swift
//  App
//
//  Created by DJ McKay on 9/6/18.
//

import Vapor
import Leaf
import Fluent
import Authentication
import FluentMySQL

struct WebsiteController: RouteCollection {
    func boot(router: Router) throws {
        let authSessionRoutes = router.grouped(User.authSessionsMiddleware())
        authSessionRoutes.get(use: indexHandler)
        authSessionRoutes.get("login", use: loginHandler)
        authSessionRoutes.post(LoginPostData.self, at: "login", use: loginPostHandler)
        authSessionRoutes.post("logout", use: logoutHandler)
        
        authSessionRoutes.get("signup", use: signupHandler)
        authSessionRoutes.post(SignupData.self, at: "signup", use: signupPostHandler2)
        let protectedRoutes = authSessionRoutes.grouped(RedirectMiddleware<User>(path: "/login"))
        protectedRoutes.get("users", User.parameter, use: userHandler)
        protectedRoutes.get("users", use: allUsersHandler)
        protectedRoutes.get("users", "create", use: createNewTeamUser)

    }
    
    func indexHandler(_ req: Request) throws -> Future<View> {
        
        let userLoggedIn = try req.isAuthenticated(User.self)
        var user: User.Public?
        if (userLoggedIn) {
            user = try req.requireAuthenticated(User.self).convertToPublic()
        }
        let showCookieMessage = req.http.cookies["cookies-accepted"] == nil
        let context = IndexContext(title: "Homepage",
                                   userLoggedIn: userLoggedIn,
                                   showCookieMessage: showCookieMessage, user: user)
        return try req.view().render("index", context)
    
    }
    
    func userHandler(_ req: Request) throws -> Future<View> {
        return try req.parameters.next(User.self)
            .flatMap(to: View.self) { user in
                
                let context = UserContext(userLoggedIn: true, title: user.name,
                                          user: user)
                return try req.view().render("user", context)
                
        }
    }
    
    func allUsersHandler(_ req: Request) throws -> Future<View> {
        let userLoggedIn = try req.isAuthenticated(User.self)
        let user = try req.requireAuthenticated(User.self)
        return user.account.get(on: req).flatMap(to: View.self) { (account) in
            return try account.users.query(on: req).all().flatMap(to: View.self, { (users) in
                let context = AllUsersContext(title: "My Team",
                                              users: users, userLoggedIn: userLoggedIn, user: user.convertToPublic(), account: account.convertToPublic(), message: nil, fieldset: [:])
                return try req.view().render("allUsers", context)
            })
        }
    }

    
    func loginHandler(_ req: Request) throws -> Future<View> {
        //User.defaultDatabase = .Coruscant
        let context: LoginContext
        if req.query[Bool.self, at: "error"] != nil {
            context = LoginContext(loginError: true)
        } else {
            context = LoginContext()
        }
        return try req.view().render("login", context)
    }
    
    func loginPostHandler(_ req: Request, userData: LoginPostData) throws -> Future<Response> {
        return User.authenticate(username: userData.username, password: userData.password, using: BCryptDigest(),on: req)
            .map(to: Response.self) { user in
                guard let user = user else {
                    return req.redirect(to: "/login?error")
                }
                try req.authenticateSession(user)
                return req.redirect(to: "/events")
        }
    }
    
    func logoutHandler(_ req: Request) throws -> Response {
        try req.unauthenticateSession(User.self)
        return req.redirect(to: "/")
    }

    
    func signupHandler(_ req: Request) throws -> Future<View> {
        let context: SignupContext
        if let message = req.query[String.self, at: "message"] {
            context = SignupContext(message: message)
        } else {
            context = SignupContext()
        }
        return try req.view().render("signup/signup", context)
    }
    
    func createNewTeamUser(_ req: Request) throws -> Future<View> {
        let user = try req.requireAuthenticated(User.self)
        guard user.isOrganizer == true else { throw Abort.redirect(to: "/error", type: .normal) } // WebAbort.errorPage(.unauthorized) }
        return user.account.get(on: req).flatMap({ (account) -> EventLoopFuture<View> in
            return TeamInvite(accountId: account.id!).create(on: req).flatMap({ (invite) in
                let data = InviteData(name: nil, username: nil, organization: account.name, inviteToken: invite.id?.uuidString)
                let context: NewTeamUserContext = NewTeamUserContext(user: user.convertToPublic(), message: nil, data: data, userLoggedIn: true, fieldset: [:])
                return try req.view().render("createUser", context)
            })
            
        })
        
    }
    
    func signupPostHandler2(_ req: Request, data: SignupData) throws -> Future<View> {
        var context = SignupContext()
        context.data = data
        do {
            try data.validate()
        } catch {
            context.userLoggedIn = false
            if let error = error as? ValidationError {
                    context.message = error.reason
                } else {
                    context.message = "Unknown Error"
                }
            return try req.view().render("signup/signup", context)
        }
        let password = try BCrypt.hash(data.password)
        
       return Account.query(on: req).filter(\.name == data.organization).first().flatMap(to: Account.self) { (account) in
        guard let account = account else {
            let newAccount = Account(name: data.organization)
            return newAccount.create(on: req)
        }
        //TODO expand this to allow a user to send a link with a uuid inviteToken
        if data.inviteToken != "invite" {
            throw KaminoBasicValidationError("Invalid inviation code.  Organization already in use.")
        }
        return req.future(account)
//        if (account == nil || account!.id == nil) {
//            let newAccount = Account(name: data.organization)
//            return newAccount.create(on: req)
//        } else {
//            return req.future(account!)
//        }
        
        } .flatMap(to: View.self, { (account) in
            let user = User(name: data.name, username: data.username, password: password, organization: data.organization, account: account.id!, isOrganizer: true)
                let results = user.create(on: req)
                return results.flatMap(to: View.self, { (user)  in
                    try req.authenticateSession(user)
                    context.userLoggedIn = try req.isAuthenticated(User.self)
                    context.user = user.convertToPublic()
                    //TODO: 
//                    let test = EmailAddress(email: "djmckay@mac.com", name: "dj")
//                    let email = MailgunEmail(from: test, cc: [test], bcc: [test], to: [test], text: "test", html: nil, subject: "test", attachments: nil)
//                    try req.make(MailgunClient.self).send([email], on: req)
                    return try req.view().render("signup/signup", context)
                })
                .catchFlatMap({ (error) -> (EventLoopFuture<View>) in
                    print(error)
                    context.userLoggedIn = false
                    if let error = error as? MySQLError {
                        if error.reason.lowercased().contains("duplicate".lowercased()) {
                            context.message = "Username already taken"
                        } else {
                            context.message = error.reason
                        }
                        
                    } else {
                        context.message = "Invalid"
                    }
                    return try req.view().render("signup/signup", context)
                })
                
            })
            .catchFlatMap({ (error) -> (EventLoopFuture<View>) in
                print(error)
                context.userLoggedIn = false
                if let error = error as? MySQLError {
                    if error.reason.lowercased().contains("duplicate".lowercased()) {
                        context.message = "Organization already in use, contact account owner to add users or choose a different Organization Name"
                    } else {
                        context.message = error.reason
                    }
                    
                } else {
                    if let error = error as? KaminoBasicValidationError {
                        context.message = error.message
                    } else {
                        context.message = "Invalid"
                    }
                }
                return try! req.view().render("signup/signup", context)
        })
        
        
        
//        return Account.query(on: req).filter(\.name == data.organization).first().flatMap { (account) in
//            if (account == nil || account!.id == nil) {
//                let newAccount = Account(name: data.organization)
//                context.message = "Account Name Not Found."
//                return try req.view().render("signup", context)
//            }
//            let user = User(name: data.name, username: data.username, password: password, organization: data.organization, account: account!.id!)
//
//                let results = user.create(on: req)
//
//                return results.flatMap(to: View.self, { (user)  in
//                    try req.authenticateSession(user)
//                    context.userLoggedIn = try req.isAuthenticated(User.self)
//                    context.user = user.convertToPublic()
//                    return try req.view().render("signup", context)
//                })
//                    .catchFlatMap({ (error) -> (EventLoopFuture<View>) in
//                        print(error)
//                        context.userLoggedIn = false
//                        if let error = error as? MySQLError {
//                            if error.reason.lowercased().contains("duplicate".lowercased()) {
//                                context.message = "Username already taken"
//                            } else {
//                                context.message = error.reason
//                            }
//
//                        } else {
//                            context.message = "Invalid"
//                        }
//                        return try req.view().render("signup", context)
//                    })
//
//            }
//             })
//        }
        
        
    }
    

}

protocol KaminoContext: Encodable {
    var userLoggedIn: Bool { get }
    var user: User.Public { get }
    var message: String? { get set }
    var fieldset: [String: String] { get set }
}

struct IndexContext: Encodable {
    let title: String
    let userLoggedIn: Bool
    let showCookieMessage: Bool
    let user: User.Public?
}

struct LoginContext: Encodable {
    let title = "Log In"
    let loginError: Bool
    let userLoggedIn: Bool
    init(loginError: Bool = false) {
        self.loginError = loginError
        self.userLoggedIn = loginError
    }
}

struct LoginPostData: Content {
    let username: String
    let password: String
}

struct UserContext: Encodable {
    var userLoggedIn: Bool = true
    let title: String
    let user: User
}

struct AllUsersContext: KaminoContext {
    let title: String
    let users: [User]
    let userLoggedIn: Bool
    let user: User.Public
    let account: Account.Public
    var message: String?
    var fieldset: [String: String] = [:]
}

struct SignupContext: Encodable {
    let title: String = "Signup"
    var message: String?
    var data: SignupData?
    var userLoggedIn: Bool = false
    var user: User.Public?
    var fieldset: [String: String] = [:]
    init(message: String? = nil) {
        self.message = message
    }
}

struct NewTeamUserContext: KaminoContext {
    var user: User.Public
    let title: String = "Invite"
    var message: String?
    var data: InviteData?
    var userLoggedIn: Bool = true
    var fieldset: [String: String] = [:]
    
}

struct InviteData: Content {
    let name: String?
    let username: String?
    let organization: String?
    let inviteToken: String?
}

struct SignupData: Content {
    let name: String
    let username: String
    let password: String
    let confirmPassword: String
    let organization: String
    let message: String?
    let inviteToken: String?
}

extension SignupData: Validatable, Reflectable {
    static func validations() throws -> Validations<SignupData> {
        var validations = Validations(SignupData.self)
        
        try validations.add(\.name, .ascii)
        try validations.add(\.username, .alphanumeric && .count(2...))  //todo change to .email
        try validations.add(\.password, .count(8...))
        validations.add("passwords match") { model in
            guard model.password == model.confirmPassword else {
                throw KaminoBasicValidationError("passwords don't match", "password")
            }
        }
        
        
        return validations
    }
    
    
}
